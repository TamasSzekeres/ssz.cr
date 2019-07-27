require "big"

require "./constants"
require "./utils"

struct BigDecimal
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
    BigDecimal.new(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

struct BigFloat
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
    BigFloat.new(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

struct BigInt
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
    BigInt.new(String.ssz_decode(io, size))
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end

struct BigRational
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
    [
      SSZ::BYTES_PER_LENGTH_OFFSET,
      SSZ::BYTES_PER_LENGTH_OFFSET,
      numerator.ssz_size,
      denominator.ssz_size
    ].sum
  end

  def ssz_encode : Bytes
    num_s = numerator.to_s
    den_s = denominator.to_s

    8.as(SSZ::Offset).ssz_encode +
    (8 + num_s.ssz_size).as(SSZ::Offset).ssz_encode +
    num_s.ssz_encode +
    den_s.ssz_encode
  end

  def ssz_encode(io : IO)
    num_s = numerator.to_s
    den_s = denominator.to_s

    8.as(SSZ::Offset).ssz_encode(io)
    (8 + num_s.ssz_size).as(SSZ::Offset).ssz_encode(io)
    num_s.ssz_encode(io)
    den_s.ssz_encode(io)
  end

  def self.ssz_decode(io : IO, size : Int32)
    num_o = SSZ::Offset.ssz_decode(io)
    den_o = SSZ::Offset.ssz_decode(io)
    num_size = den_o - num_o
    den_size = size - num_size - 8
    den_size = 0 if size < 0

    num = BigInt.ssz_decode(io, num_size)
    den = BigInt.ssz_decode(io, den_size)
    BigRational.new(num, den)
  end

  def self.ssz_decode(bytes : Bytes)
    ssz_decode(IO::Memory.new(bytes), bytes.size)
  end
end
