require "./codec"

module SSZ
  annotation Ignored
  end

  module Serializable
    macro included
      def self.ssz_basic? : Bool
        false
      end

      def self.ssz_variable? : Bool
        instance = allocate
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance.ssz_variable?
      end

      def self.new(io : IO, size : Int32 = 0)
        instance = allocate
        instance.initialize(__io_for_ssz_decoding: io, __size_for_ssz_decoding: size)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end

      def self.ssz_decode(io : IO, size : Int32 = 0)
        new(io, size)
      end

      macro inherited
        def self.new(io : IO, size : Int32 = 0)
          super
        end
      end
    end

    def initialize(*, __io_for_ssz_decoding io : IO, __size_for_ssz_decoding size : Int32 = 0)
      if ssz_variable?
        offsets = [] of SSZ::Offset
        {% for ivar in @type.instance_vars %}
          {% unless ivar.annotation(::SSZ::Ignored) %}
            if {{ivar.type}}.ssz_variable?
              offsets.push(SSZ::Offset.ssz_decode(io))
            else
              @{{ivar}} = {{ivar.type}}.ssz_decode(io)
            end
          {% end %}
        {% end %}
        if offsets.size > 0
          offset_i = 0
          {% for ivar in @type.instance_vars %}
            {% unless ivar.annotation(::SSZ::Ignored) %}
              if {{ivar.type}}.ssz_variable?
                element_size = offset_i < (offsets.size - 1) ? offsets[offset_i + 1] - offsets[offset_i] : 0
                @{{ivar}} = {{ivar.type}}.ssz_decode(io, element_size)
              end
              offset_i += 1
            {% end %}
          {% end %}
        end
      else
        {% for ivar in @type.instance_vars %}
          {% unless ivar.annotation(::SSZ::Ignored) %}
            @{{ivar}} = {{ivar.type}}.ssz_decode(io)
          {% end %}
        {% end %}
      end
    end

    def ssz_basic? : Bool
      false
    end

    def ssz_variable? : Bool
      {% for ivar in @type.instance_vars %}
        {% unless ivar.annotation(::SSZ::Ignored) %}
          return true if {{ivar.type}}.ssz_variable?
        {% end %}
      {% end %}
      false
    end

    def ssz_size : Int32
      sum = 0
      {% for ivar in @type.instance_vars %}
        {% unless ivar.annotation(::SSZ::Ignored) %}
          {% if ivar.type.union? %}
            sum += {{ivar.type}}.ssz_size(@{{ivar}})
          {% else %}
            sum += @{{ivar}}.ssz_size
          {% end %}
          sum += BYTES_PER_LENGTH_OFFSET if {{ivar.type}}.ssz_variable?
        {% end %}
      {% end %}
      sum
    end

    def ssz_encode(io : IO)
      {% unless @type.instance_vars.empty? %}
        ivars = {{@type.instance_vars}}
        ivar_types = ivars.map(&.class)
        ignored = Array(Bool).new(initial_capacity: ivars.size)
        is_union = Array(Bool).new(initial_capacity: ivars.size)
        {% for ivar in @type.instance_vars %}
          {% if ivar.annotation(::SSZ::Ignored) %}
            ignored.push(true)
          {% else %}
            ignored.push(false)
          {% end %}

          {% if ivar.type.union? %}
            is_union.push(true)
          {% else %}
            is_union.push(false)
          {% end %}
        {% end %}

        fixed_parts = ivars.map_with_index do |element, i|
          !ignored[i] && !is_union[i] && element.ssz_fixed? ? element : nil
        end
        variable_parts = ivars.map_with_index do |element, i|
          is_union[i] || (!ignored[i] && element.ssz_variable?) ? element : nil
        end

        fixed_lengths = fixed_parts.map_with_index { |part, i| part.nil? ? (ignored[i] ? 0 : SSZ::BYTES_PER_LENGTH_OFFSET) : part.ssz_size }
        variable_lengths = variable_parts.map_with_index do |part, i|
          size = part.nil? ? 0 : part.ssz_size
          if is_union[i]
            size += SSZ::BYTES_PER_LENGTH_OFFSET
          end
          size
        end

        sum_fixed_lengths = fixed_lengths.sum
        variable_offsets = variable_lengths.map_with_index do |l, i|
          (sum_fixed_lengths + variable_lengths.first(i).sum).as(SSZ::Offset)
        end
        fixed_parts = fixed_parts.map_with_index { |part, i| part.nil? ? variable_offsets[i] : part }

        fixed_parts.each_with_index do |part, i|
          part.ssz_encode(io) unless ignored[i]
        end
        {% for ivar, i in @type.instance_vars %}
          unless ignored[{{i}}]
            {% if ivar.type.union? %}
              {{ivar.type}}.ssz_encode(io, variable_parts[{{i}}].as({{ivar.type}}))
            {% else %}
              variable_parts[{{i}}].ssz_encode(io)
            {% end %}
          end
        {% end %}
      {% end %}
    end
  end
end
