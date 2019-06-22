require "../spec_helper"

describe SSZ do
  describe Nil do
    describe "ssz_encode" do
      it "should encode nil" do
        nil.ssz_encode.should eq(Bytes.empty)
      end
    end
  end

  describe Int do
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
end
