require "semantic_version"

require "./codec"

struct SemanticVersion
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
    SemanticVersion.parse(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

struct SemanticVersion::Prerelease
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
    Prerelease.parse(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end
