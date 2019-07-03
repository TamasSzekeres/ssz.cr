require "./constants"

class Object
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
    size = ssz_size
    io = IO::Memory.new(size)
    ssz_encode(io)
    buffer = Bytes.new(size)
    io.seek(-size, IO::Seek::Current)
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
    self.ssz_decode(IO::Memory.new(bytes))
  end
end

struct Nil
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
  def self.ssz_decode(io : IO, size : Int32 = 0)
    {% if T.union? %}
      offsets = [SSZ::Offset.ssz_decode(io).to_i32]
      while offsets.size * SSZ::BYTES_PER_LENGTH_OFFSET < offsets.first
        offsets.push(SSZ::Offset.ssz_decode(io).to_i32)
      end
      offsets.map_with_index do |offset, i|
        io.pos = offset
        next_offset = (i < offsets.size - 1) ? offsets[i + 1] : size - offsets.last
        T.ssz_decode(io, next_offset - offset)
      end
    {% else %}
    {% end %}
  end
end

class String
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
    io.read_string(size)
  end
end

struct Union
  def self.ssz_variable? : Bool
    true
  end

  def self.ssz_fixed? : Bool
    false
  end

  def self.ssz_size(value : self) : Int32
    SSZ::BYTES_PER_LENGTH_OFFSET + value.ssz_size
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
    {% for utype, i in @type.union_types %}
    if value.is_a?({{utype}})
      {{i}}.as(SSZ::Offset).ssz_encode(io)
      value.ssz_encode(io)
      return
    end
    {% end %}
  end

  def self.ssz_decode(io : IO, size : Int32 = 0)
    type_index = SSZ::Offset.ssz_decode(io)
    {% for utype, i in @type.union_types %}
    if type_index == {{i}}
      return {{utype}}.ssz_decode(io, size - SSZ::BYTES_PER_LENGTH_OFFSET)
    end
    {% end %}
  end
end
