require "./encode"

module SSZ
  annotation Field
  end

  annotation Ignored
  end

  module Serializable
    def ssz_variable? : Bool
      {% for ivar in @type.instance_vars %}
        {% unless ivar.annotation(::SSZ::Ignored) %}
          return true if @{{ivar}}.ssz_variable?
        {% end %}
      {% end %}
      false
    end

    def ssz_size : Int32
      sum = 0
      {% for ivar in @type.instance_vars %}
        {% unless ivar.annotation(::SSZ::Ignored) %}
          sum += @{{ivar}}.ssz_size
          sum += BYTES_PER_LENGTH_OFFSET if @{{ivar}}.ssz_variable?
        {% end %}
      {% end %}
      sum
    end

    def ssz_encode(io : IO)
      {% unless @type.instance_vars.empty? %}
        ivars = {{@type.instance_vars}}
        ignored = Array(Bool).new(ivars.size)
        {% for ivar in @type.instance_vars %}
          {% if ivar.annotation(::SSZ::Ignored) %}
            ignored.push(true)
          {% else %}
            ignored.push(false)
          {% end %}
        {% end %}

        fixed_parts = ivars.map_with_index {|element, i| !ignored[i] && element.ssz_fixed? ? element : nil}
        variable_parts = ivars.map_with_index {|element, i| !ignored[i] && element.ssz_variable? ? element : nil}

        fixed_lengths = fixed_parts.map_with_index { |part, i| part.nil? ? (ignored[i] ? 0 : SSZ::BYTES_PER_LENGTH_OFFSET) : part.ssz_size }
        variable_lengths = variable_parts.map { |part| part.nil? ? 0 : part.ssz_size }

        sum_fixed_lengths = fixed_lengths.sum
        variable_offsets = variable_lengths.map_with_index do |l, i|
          (sum_fixed_lengths + variable_lengths.first(i).sum).as(SSZ::Offset)
        end
        fixed_parts = fixed_parts.map_with_index { |part, i| part.nil? ? variable_offsets[i] : part }

        fixed_parts.each_with_index do |part, i|
          part.ssz_encode(io) unless ignored[i]
        end
        variable_parts.each_with_index do |part, i|
          part.ssz_encode(io) unless ignored[i]
        end
      {% end %}
    end
  end
end
