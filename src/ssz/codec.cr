require "./constants"

class Object
  @[NoInline]
  def ssz_variable? : Bool
    raise "Unimplemented method: " + {{@def.name.stringify}}
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

  def self.ssz_decode(io : IO)
    raise "Unimplemented method: " + {{@def.name.stringify}}
  end

  def self.ssz_decode(bytes : Bytes)
    self.ssz_decode(IO::Memory.new(bytes))
  end
end

struct Nil
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

  def self.ssz_decode(bytes : Bytes)
    nil
  end

  def self.ssz_decode(io : IO)
    nil
  end
end

struct Number
  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    io.write_bytes(self, IO::ByteFormat::LittleEndian)
  end

  def self.ssz_decode(io : IO)
    from_io(io, IO::ByteFormat::LittleEndian)
  end
end

struct Enum
  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    io.write_bytes(value, IO::ByteFormat::LittleEndian)
  end

  def self.ssz_decode(io : IO)
    new io.read_bytes(values.first.value.class, IO::ByteFormat::LittleEndian)
  end
end

struct Char
  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    ord.ssz_encode(io)
  end

  def self.ssz_decode(io : IO)
    Int32.from_io(io, IO::ByteFormat::LittleEndian).unsafe_chr
  end
end

struct Bool
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
end

module Enumerable(T)
  def ssz_variable? : Bool
    true
  end

  def ssz_size : Int32
    reduce(0) do |acc, element|
      acc + element.ssz_size + (element.ssz_variable? ? SSZ::BYTES_PER_LENGTH_OFFSET : 0)
    end
  end

  def ssz_encode(io : IO)
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
  end
end

class String
  def ssz_variable? : Bool
    true
  end

  def ssz_size : Int32
    size * sizeof(Char)
  end

  def ssz_encode(io : IO)
    each_char &.ssz_encode(io)
  end
end
