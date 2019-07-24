require "openssl"

module SSZ
  def self.hash(data : Bytes) : Bytes
    underlying_io = IO::Memory.new(String.new(data))
    io = OpenSSL::DigestIO.new(underlying_io, "SHA256")
    buffer = Bytes.new(256)
    io.read(buffer)
    io.digest
  end
end
