require "uuid"

require "./constants"

class Object
  @[NoInline]
  def self.ssz_basic? : Bool
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  @[NoInline]
  def ssz_basic? : Bool
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  @[NoInline]
  def self.ssz_variable? : Bool
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  @[NoInline]
  def ssz_variable? : Bool
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  @[NoInline]
  def self.ssz_fixed? : Bool
    !self.ssz_variable?
  end

  @[NoInline]
  def ssz_fixed? : Bool
    !ssz_variable?
  end

  @[NoInline]
  def ssz_size : Int32
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  @[NoInline]
  def ssz_encode : Bytes
    _ssz_size = ssz_size
    io = IO::Memory.new(_ssz_size)
    ssz_encode(io)
    buffer = Bytes.new(_ssz_size)
    io.seek(-_ssz_size, IO::Seek::Current)
    io.read_fully(buffer)
    buffer
  end

  @[NoInline]
  def ssz_encode(io : IO)
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  def self.ssz_decode(bytes : Bytes)
    self.ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

struct Nil
  def self.ssz_basic? : Bool
    true
  end

  def ssz_basic? : Bool
    true
  end

  def self.ssz_variable? : Bool
    false
  end

  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    0
  end

  def ssz_encode : Bytes
    Bytes.empty
  end

  def ssz_encode(io : IO)
  end

  def self.ssz_decode(bytes : Bytes, size : Int32 = 0)
    nil
  end

  def self.ssz_decode(io : IO)
    nil
  end
end

struct Number
  def self.ssz_basic? : Bool
    true
  end

  def ssz_basic? : Bool
    true
  end

  def self.ssz_variable? : Bool
    false
  end

  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    io.write_bytes(self, IO::ByteFormat::LittleEndian)
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    from_io(io, IO::ByteFormat::LittleEndian)
  end
end

struct Enum
  def self.ssz_basic? : Bool
    true
  end

  def ssz_basic? : Bool
    true
  end

  def self.ssz_variable? : Bool
    false
  end

  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    io.write_bytes(value, IO::ByteFormat::LittleEndian)
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    new io.read_bytes(values.first.value.class, IO::ByteFormat::LittleEndian)
  end
end

struct Char
  def self.ssz_basic? : Bool
    true
  end

  def ssz_basic? : Bool
    true
  end

  def self.ssz_variable? : Bool
    false
  end

  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(Char)
  end

  def ssz_encode(io : IO)
    ord.ssz_encode(io)
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    Int32.from_io(io, IO::ByteFormat::LittleEndian).unsafe_chr
  end
end

struct Bool
  def self.ssz_basic? : Bool
    true
  end

  def ssz_basic? : Bool
    true
  end

  def self.ssz_variable? : Bool
    false
  end

  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    1
  end

  def ssz_encode : Bytes
    Bytes[self ? 1_u8 : 0_u8]
  end

  def ssz_encode(io : IO)
    byte = self ? 1_u8 : 0_u8
    io.write_bytes(byte)
  end

  def self.ssz_decode(bytes : Bytes)
    bytes[0] != 0_u8
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    io.read_byte.not_nil! != 0_u8
  end
end

module Enumerable(T)
  def self.ssz_basic? : Bool
    false
  end

  def ssz_basic? : Bool
    false
  end

  def ssz_variable? : Bool
    true
  end

  def ssz_size : Int32
    {% if T.union? %}
      reduce(0) do |acc, element|
        acc + T.ssz_size(element) + SSZ::BYTES_PER_LENGTH_OFFSET
      end
    {% else%}
      reduce(0) do |acc, element|
        acc + element.ssz_size + (element.ssz_variable? ? SSZ::BYTES_PER_LENGTH_OFFSET : 0)
      end
    {% end %}
  end

  def ssz_encode(io : IO)
    {% if T.union? %}
      offset = (size * sizeof(SSZ::Offset)).as(SSZ::Offset)
      each_with_index do |element, i|
        offset.ssz_encode(io)
        offset += T.ssz_size(element)
      end
      each_with_index do |element, i|
        T.ssz_encode(io, element)
      end
    {% else %}
      fixed_parts = map { |element| element.ssz_fixed? ? element : nil }
      variable_parts = map { |element| element.ssz_variable? ? element : nil }

      fixed_lengths = fixed_parts.map { |part| part.nil? ? SSZ::BYTES_PER_LENGTH_OFFSET : part.ssz_size }
      variable_lengths = variable_parts.map &.ssz_size

      sum_fixed_lengths = fixed_lengths.sum
      variable_offsets = map_with_index do |e, i|
        (sum_fixed_lengths + variable_lengths.first(i).sum).as(SSZ::Offset)
      end
      fixed_parts = fixed_parts.map_with_index { |part, i| part.nil? ? variable_offsets[i] : part }

      fixed_parts.each &.ssz_encode(io)
      variable_parts.each &.ssz_encode(io)
    {% end %}
  end
end

class Array(T)
  def self.ssz_variable? : Bool
    true
  end

  def ssz_variable? : Bool
    true
  end

  def ssz_size : Int32
    {% if T.union? %}
      size * SSZ::BYTES_PER_LENGTH_OFFSET +
      reduce(0) do |acc, element|
        acc + T.ssz_size(element)
      end
    {% else %}
      if T.ssz_variable?
        size * SSZ::BYTES_PER_LENGTH_OFFSET +
        reduce(0) do |acc, element|
          acc + element.ssz_size
        end
      else
        size * first.ssz_size
      end
    {% end %}
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    end_pos = size > 0 ? io.pos + size : Int32::MAX
    arr = Array(T).new

    if T.ssz_variable?
      raise "Invalid `size` parameter!" if size <= SSZ::BYTES_PER_LENGTH_OFFSET
      offsets = [SSZ::Offset.ssz_decode(io).to_i32]
      while offsets.size * SSZ::BYTES_PER_LENGTH_OFFSET < offsets.first
        offsets.push(SSZ::Offset.ssz_decode(io).to_i32)
      end
      offsets.each_with_index do |offset, i|
        io.pos = offset
        next_offset = (i < offsets.size - 1) ? offsets[i + 1] : size
        arr.push(T.ssz_decode(io, next_offset - offset))
      end
    else
      while io.pos < end_pos
        begin
          arr << T.ssz_decode(io).as(T)
        rescue IO::EOFError
          break
        end
      end
    end
    arr
  end
end

struct StaticArray(T, N)
  def self.ssz_variable? : Bool
    T.ssz_variable?
  end

  def ssz_variable? : Bool
    T.ssz_variable?
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    if T.ssz_variable?
      offsets = Array(SSZ::Offset).new(N) do
        SSZ::Offset.ssz_decode(io, SSZ::BYTES_PER_LENGTH_OFFSET)
      end
      StaticArray(T, N).new do |i|
        if io.pos != offsets[i]
          raise IO::Error.new("Invalid io position: #{io.pos}. Must be #{offsets[i]} !")
        end
        element_size = i < (N - 1) ? offsets[i + 1] - offsets[i] : size - offsets[i]
        element_size = 0 if element_size < 0
        T.ssz_decode(io, element_size)
      end
    else
      StaticArray(T, N).new do
        T.ssz_decode(io)
      end
    end
  end
end

struct Slice(T)
  def self.ssz_variable? : Bool
    true
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    arr = Array(T).ssz_decode(io, size)
    Slice(T).new(arr.size) { |i| arr[i] }
  end
end

struct Set(T)
  def self.ssz_variable? : Bool
    true
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    arr = Array(T).ssz_decode(io, size)
    Set(T).new(arr)
  end
end

class String
  def self.ssz_basic? : Bool
    false
  end

  def ssz_basic? : Bool
    false
  end

  def self.ssz_variable? : Bool
    true
  end

  def ssz_variable? : Bool
    true
  end

  def ssz_size : Int32
    bytesize
  end

  def ssz_encode : Bytes
    Bytes.new(bytes.to_unsafe, bytesize)
  end

  def ssz_encode(io : IO)
    bytes.ssz_encode(io)
  end

  def self.ssz_decode(bytes : Bytes)
    new(bytes)
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    if size > 0
      io.read_string(size)
    else
      io.gets_to_end
    end
  end
end

struct Union
  def self.ssz_basic? : Bool
    false
  end

  def self.ssz_variable? : Bool
    true
  end

  def self.ssz_fixed? : Bool
    false
  end

  def self.ssz_size(value : self) : Int32
    SSZ::BYTES_PER_LENGTH_OFFSET + value.ssz_size
  end

  def self.ssz_type_index(value : self) : SSZ::Offset
    {% if @type.nilable? %}
      if value.nil?
        return 0.as(SSZ::Offset)
      end

      type_index = 1.as(SSZ::Offset)
      {% for utype in @type.union_types %}
        if value.is_a?({{utype}})
          return type_index
        else
          type_index += 1
        end
      {% end %}
    {% else %}
      {% for utype, i in @type.union_types %}
        if value.is_a?({{utype}})
          return {{i}}.as(SSZ::Offset)
        end
      {% end %}
    {% end %}

    # Not-reachable
    raise "Invalid input!"
  end

  def self.ssz_encode(value : self) : Bytes
    size = self.ssz_size(value)
    io = IO::Memory.new(size)
    self.ssz_encode(io, value)
    buffer = Bytes.new(size)
    io.seek(-size, IO::Seek::Current)
    io.read_fully(buffer)
    buffer
  end

  def self.ssz_encode(io : IO, value : self)
    ssz_type_index(value).ssz_encode(io)
    value.ssz_encode(io)
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    type_index = SSZ::Offset.ssz_decode(io)
    {% if @type.nilable? %}
      if type_index == 0
        return nil
      end

      ti = 1.as(SSZ::Offset)
      {% for utype in @type.union_types %}
      if type_index == ti
        return {{utype}}.ssz_decode(io, size - SSZ::BYTES_PER_LENGTH_OFFSET)
      else
        ti += 1
      end
      {% end %}
    {% else %}
      {% for utype, i in @type.union_types %}
      if type_index == {{i}}
        return {{utype}}.ssz_decode(io, size - SSZ::BYTES_PER_LENGTH_OFFSET)
      end
      {% end %}
    {% end %}

    raise "Invalid input!"
  end
end

struct UUID
  def self.ssz_basic? : Bool
    false
  end

  def ssz_basic? : Bool
    false
  end

  def self.ssz_variable? : Bool
    true
  end

  def ssz_variable? : Bool
    true
  end

  def self.ssz_fixed? : Bool
    false
  end

  def ssz_fixed? : Bool
    false
  end

  def ssz_size : Int32
    to_s.ssz_size
  end

  def ssz_encode : Bytes
    to_s.ssz_encode
  end

  def ssz_encode(io : IO)
    to_s.ssz_encode(io)
  end

  def self.ssz_decode(io : IO, size : Int32)
    UUID.new(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

class URI
  def self.ssz_basic? : Bool
    false
  end

  def ssz_basic? : Bool
    false
  end

  def self.ssz_variable? : Bool
    true
  end

  def ssz_variable? : Bool
    true
  end

  def self.ssz_fixed? : Bool
    false
  end

  def ssz_fixed? : Bool
    false
  end

  def ssz_size : Int32
    to_s.ssz_size
  end

  def ssz_encode : Bytes
    to_s.ssz_encode
  end

  def ssz_encode(io : IO)
    to_s.ssz_encode(io)
  end

  def self.ssz_decode(io : IO, size : Int32)
    URI.parse(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end
