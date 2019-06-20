class Object
  def ssz_variable? : Bool
    raise "Unimplemented method: #{__METHOD__}"
  end

  def ssz_size : Int32
    raise "Unimplemented method: #{__METHOD__}"
  end

  def ssz_encode : Bytes
    size = ssz_size
    io = IO::Memory.new(size)
    ssz_encode(io)
    buffer = Bytes.new(size)
    io.seek(-size, IO::Seek::Current)
    io.read_fully(buffer)
    buffer
  end

  def ssz_encode(io : IO)
    raise "Unimplemented method: #{__METHOD__}"
  end
end

struct Int
  def ssz_variable? : Bool
    false
  end

  def ssz_size : Int32
    sizeof(self)
  end

  def ssz_encode(io : IO)
    io.write_bytes(self, IO::ByteFormat::LittleEndian)
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
