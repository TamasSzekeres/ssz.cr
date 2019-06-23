require "../spec_helper"

describe SSZ do
  describe Nil do
    describe "#ssz_variable?" do
      it "should always return false" do
        nil.ssz_variable?.should be_false
      end
    end

    describe "#ssz_fixed?" do
      it "should always return true" do
        nil.ssz_fixed?.should be_true
      end
    end

    describe "#ssz_size" do
      it "should always return 0" do
        nil.ssz_size.should eq(0)
      end
    end

    describe "#ssz_encode" do
      it "should encode nil" do
        io = IO::Memory.new()
        nil.ssz_encode(io)
        io.pos.should eq(0)

        nil.ssz_encode.should eq(Bytes.empty)
      end
    end

    describe "#ssz_decode" do
      it "should always return nil" do
        bytes = Bytes[0_u8, 1_u8]
        io = IO::Memory.new(bytes)
        Nil.ssz_decode(io).should eq(nil)
        io.pos.should eq(0)

        Nil.ssz_decode(bytes).should eq(nil)
      end
    end
  end

  describe Number do
    describe "#ssz_variable?" do
      it "should always return false" do
        0_i8.ssz_variable?.should be_false
        0_i16.ssz_variable?.should be_false
        0_i32.ssz_variable?.should be_false
        0_u8.ssz_variable?.should be_false
        0_u16.ssz_variable?.should be_false
        0_u32.ssz_variable?.should be_false

        0.0_f32.ssz_variable?.should be_false
        0.0_f64.ssz_variable?.should be_false
      end
    end

    describe "#ssz_fixed?" do
      it "should always return true" do
        0_i8.ssz_fixed?.should be_true
        0_i16.ssz_fixed?.should be_true
        0_i32.ssz_fixed?.should be_true
        0_u8.ssz_fixed?.should be_true
        0_u16.ssz_fixed?.should be_true
        0_u32.ssz_fixed?.should be_true

        0.0_f32.ssz_fixed?.should be_true
        0.0_f64.ssz_fixed?.should be_true
      end
    end

    describe "#ssz_size" do
      it "should return size" do
        0_i8.ssz_size.should eq(1)
        0_i16.ssz_size.should eq(2)
        0_i32.ssz_size.should eq(4)
        0_u8.ssz_size.should eq(1)
        0_u16.ssz_size.should eq(2)
        0_u32.ssz_size.should eq(4)

        0.0_f32.ssz_size.should eq(4)
        0.0_f64.ssz_size.should eq(8)
      end
    end

    describe "#ssz_encode" do
      it "should encode integer" do
        0x56_i8.ssz_encode.should eq(Bytes[0x56_u8])
        0xf1_u8.ssz_encode.should eq(Bytes[0xf1_u8])
        0x3375_i16.ssz_encode.should eq(Bytes[0x75_u8, 0x33_u8])
        0x637a_u16.ssz_encode.should eq(Bytes[0x7a_u8, 0x63_u8])
        0x5c3e8b1f_i32.ssz_encode.should eq(Bytes[0x1f_u8, 0x8b_u8, 0x3e_u8, 0x5c_u8])
        0x82cd9ab3_u32.ssz_encode.should eq(Bytes[0xb3_u8, 0x9a_u8, 0xcd_u8, 0x82_u8])
        0x61ac721f8e427211_i64.ssz_encode.should eq(Bytes[0x11_u8, 0x72_u8, 0x42_u8, 0x8e_u8, 0x1f_u8, 0x72_u8, 0xac_u8, 0x61_u8])
        0x92c87ce38e4292b7_u64.ssz_encode.should eq(Bytes[0xb7_u8, 0x92_u8, 0x42_u8, 0x8e_u8, 0xe3_u8, 0x7c_u8, 0xc8_u8, 0x92_u8])
      end

      it "should encode float" do
        0_f32.ssz_encode.should eq(Bytes[0_u8, 0_u8, 0_u8, 0_u8])
        12.34_f32.ssz_encode.should eq(Bytes[164_u8, 112_u8, 69_u8, 65_u8])

        0_f64.ssz_encode.should eq(Bytes[0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8])
        12.34_f64.ssz_encode.should eq(Bytes[174_u8, 71_u8, 225_u8, 122_u8, 20_u8, 174_u8, 40_u8, 64_u8])
      end
    end

    describe "#ssz_encode" do
      it "should decode Int8" do
        bytes = Bytes[120_u8]
        io = IO::Memory.new(bytes)
        Int8.ssz_decode(io).should eq(120_i8)
        io.pos.should eq(1)

        Int8.ssz_decode(bytes).should eq(120_i8)
      end

      it "should decode Int16" do
        bytes = Bytes[0x12_u8, 0x11_u8]
        io = IO::Memory.new(bytes)
        Int16.ssz_decode(io).should eq(4370_i16)
        io.pos.should eq(2)

        Int16.ssz_decode(bytes).should eq(4370_i16)
      end

      it "should decode Int32" do
        bytes = Bytes[0x12_u8, 0x11_u8, 0x10_u8, 0x5_u8]
        io = IO::Memory.new(bytes)
        Int32.ssz_decode(io).should eq(84939026_i32)
        io.pos.should eq(4)

        Int32.ssz_decode(bytes).should eq(84939026_i32)
      end

      it "should decode UInt8" do
        bytes = Bytes[120_u8]
        io = IO::Memory.new(bytes)
        UInt8.ssz_decode(io).should eq(120_u8)
        io.pos.should eq(1)

        UInt8.ssz_decode(bytes).should eq(120_u8)
      end

      it "should decode UInt16" do
        bytes = Bytes[0x12_u8, 0x11_u8]
        io = IO::Memory.new(bytes)
        UInt16.ssz_decode(io).should eq(4370_u16)
        io.pos.should eq(2)

        UInt16.ssz_decode(bytes).should eq(4370_u16)
      end

      it "should decode UInt32" do
        bytes = Bytes[0x12_u8, 0x11_u8, 0x10_u8, 0x5_u8]
        io = IO::Memory.new(bytes)
        UInt32.ssz_decode(io).should eq(84939026_u32)
        io.pos.should eq(4)

        UInt32.ssz_decode(bytes).should eq(84939026_u32)
      end

      it "should decode Float32" do
        bytes = Bytes[164_u8, 112_u8, 69_u8, 65_u8]
        io = IO::Memory.new(bytes)
        Float32.ssz_decode(io).should eq(12.34_f32)
        io.pos.should eq(4)

        Float32.ssz_decode(bytes).should eq(12.34_f32)
      end

      it "should decode Float64" do
        bytes = Bytes[174_u8, 71_u8, 225_u8, 122_u8, 20_u8, 174_u8, 40_u8, 64_u8]
        io = IO::Memory.new(bytes)
        Float64.ssz_decode(io).should eq(12.34_f64)
        io.pos.should eq(8)

        Float64.ssz_decode(bytes).should eq(12.34_f64)
      end
    end
  end

  describe Enum do
    describe "#ssz_encode" do
      it "should encode enum" do
        Color::Red.ssz_encode.should eq(Bytes[0_u8, 0_u8, 0_u8, 0_u8])
        Color::Green.ssz_encode.should eq(Bytes[1_u8, 0_u8, 0_u8, 0_u8])
        Color::Blue.ssz_encode.should eq(Bytes[2_u8, 0_u8, 0_u8, 0_u8])

        Direction::None.ssz_encode.should eq(Bytes[0_u8])
        Direction::Left.ssz_encode.should eq(Bytes[10_u8])
        Direction::Down.ssz_encode.should eq(Bytes[13_u8])
      end
    end
  end

  describe Char do
    describe "#ssz_encode" do
      it "should encode char" do
        Char::ZERO.ssz_encode.should eq(Bytes[0_u8, 0_u8, 0_u8, 0_u8])
        Char::MAX.ssz_encode.should eq(Bytes[0xff_u8, 0xff_u8, 0x10_u8, 0_u8])
        'A'.ssz_encode.should eq(Bytes[65_u8, 0_u8, 0_u8, 0_u8])
        '𐒙'.ssz_encode.should eq(Bytes[0x99_u8, 4_u8, 1_u8, 0_u8])
      end
    end
  end

  describe Bool do
    describe "ssz_encode" do
      it "should encode boolean" do
        true.ssz_encode.should eq(Bytes[1_u8])
        false.ssz_encode.should eq(Bytes[0_u8])
      end
    end
  end

  describe String do
    describe "ssz_encode" do
      it "should encode string" do
        "SSZ".ssz_encode.should eq(Bytes[83, 0, 0, 0, 83, 0, 0, 0, 90, 0, 0, 0])
      end
    end
  end

  describe Bytes do
    describe "#ssz_encode" do
      it "should encode bytes" do
        Bytes.empty.ssz_encode.should eq(Bytes.empty)
        Bytes[0_u8, 120_u8, 250_u8].ssz_encode.should eq(Bytes[0_u8, 120_u8, 250_u8])
      end
    end
  end

  describe Slice(Int16) do
    describe "#ssz_encode" do
      it "should encode slice" do
        Slice(Int16).empty.ssz_encode.should eq(Bytes.empty)
        Slice(Int16).new(3) { |i| (i + 10).to_i16 }.ssz_encode.should eq(Bytes[10_u8, 0_u8, 11_u8, 0_u8, 12_u8, 0_u8])
      end
    end
  end

  describe Array do
    describe "#ssz_size" do
      it "should calc encoded size" do
        [1_i32, 24_i32].ssz_size.should eq(8)
        [nil, 34_u8, false, 16_i16].ssz_size.should eq(4)
        [0_u8, "AB", 0_u8].ssz_size.should eq(14)
      end
    end

    describe "#ssz_encode" do
      it "should encode array" do
        [0x5c3e8b1f_i32, 0x637a_u16].ssz_encode.should eq(Bytes[0x1f_u8, 0x8b_u8, 0x3e_u8, 0x5c_u8, 0x7a_u8, 0x63_u8])
        [0_u8, "AB", 0_u8].ssz_encode.should eq(Bytes[0, 6, 0, 0, 0, 0, 65, 0, 0, 0, 66, 0, 0, 0])
      end
    end
  end

  describe Set do
    describe "#ssz_encode" do
      it "should encode set" do
        Set{1, 2}.ssz_encode.should eq(Bytes[1_u8, 0_u8, 0_u8, 0_u8, 2_u8, 0_u8, 0_u8, 0_u8])
        Set{101_u8, 22_u8}.ssz_encode.should eq(Bytes[101_u8, 22_u8])
      end
    end
  end
end
