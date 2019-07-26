require "../spec_helper"

describe SSZ do
  describe "Nil#hash_tree_root" do
    it "should return hash_tree_root" do
      nil.hash_tree_root.should eq(SSZ::EMPTY_CHUNK)
    end
  end

  describe "Bool#hash_tree_root" do
    it "should return hash_tree_root" do
      false.hash_tree_root.should eq(SSZ::EMPTY_CHUNK)

      true_root = true.hash_tree_root
      true_root.size.should eq(SSZ::BYTES_PER_CHUNK)
      true_root.first.should eq(1_u8)
      true_root[1..-1].sum.should eq(0)
    end
  end

  describe "Number#hash_tree_root" do
    it "should return hash_tree_root" do
      106_i8.hash_tree_root.should eq(Bytes[106].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      212_u8.hash_tree_root.should eq(Bytes[212].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x5b5a_i16.hash_tree_root.should eq(Bytes[0x5a, 0x5b].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x6a8b_u16.hash_tree_root.should eq(Bytes[0x8b, 0x6a].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x5c3e8b1f_i32.hash_tree_root.should eq(Bytes[0x1f_u8, 0x8b_u8, 0x3e_u8, 0x5c_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x82cd9ab3_u32.hash_tree_root.should eq(Bytes[0xb3_u8, 0x9a_u8, 0xcd_u8, 0x82_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x925736816265_i64.hash_tree_root.should eq(Bytes[0x65, 0x62, 0x81, 0x36, 0x57, 0x92].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      0x925736816265_u64.hash_tree_root.should eq(Bytes[0x65, 0x62, 0x81, 0x36, 0x57, 0x92].resize(SSZ::BYTES_PER_CHUNK, 0_u8))

      12.34_f32.hash_tree_root.should eq(Bytes[164_u8, 112_u8, 69_u8, 65_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      12.34_f64.hash_tree_root.should eq(Bytes[174_u8, 71_u8, 225_u8, 122_u8, 20_u8, 174_u8, 40_u8, 64_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
    end
  end

  describe "Enum#hash_tree_root" do
    it "should return hash_tree_root" do
      Color::Red.hash_tree_root.should eq(SSZ::EMPTY_CHUNK)
      Color::Green.hash_tree_root.should eq(Bytes[1_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      Color::Blue.hash_tree_root.should eq(Bytes[2_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))

      Direction::None.hash_tree_root.should eq(SSZ::EMPTY_CHUNK)
      Direction::Left.hash_tree_root.should eq(Bytes[10_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      Direction::Down.hash_tree_root.should eq(Bytes[13_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
    end
  end

  describe "Char#hash_tree_root" do
    it "should return hash_tree_root" do
      Char::ZERO.hash_tree_root.should eq(SSZ::EMPTY_CHUNK)
      Char::MAX.hash_tree_root.should eq(Bytes[0xff_u8, 0xff_u8, 0x10_u8, 0_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      'A'.hash_tree_root.should eq(Bytes[65_u8, 0_u8, 0_u8, 0_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
      '𐒙'.hash_tree_root.should eq(Bytes[0x99_u8, 4_u8, 1_u8, 0_u8].resize(SSZ::BYTES_PER_CHUNK, 0_u8))
    end
  end

  describe "String#hash_tree_root" do
    it "should return hash_tree_root" do
      root = Bytes[246, 148, 185, 205, 71, 242, 109, 31, 103, 67, 93, 76, 244, 199, 71, 142, 123, 143, 27, 254, 9, 106, 73, 128, 193, 183, 253, 29, 118, 90, 212, 143]
      "ABC".hash_tree_root.should eq(root)
    end
  end

  describe "Enumerable(T)#hash_tree_root" do
    it "should return hash_tree_root" do
      root = Bytes[246, 148, 185, 205, 71, 242, 109, 31, 103, 67, 93, 76, 244, 199, 71, 142, 123, 143, 27, 254, 9, 106, 73, 128, 193, 183, 253, 29, 118, 90, 212, 143]
      ([65_u8, 66_u8, 67_u8] of UInt8).hash_tree_root.should eq(root)
      Bytes[65_u8, 66_u8, 67_u8].hash_tree_root.should eq(root)
      Set{65_u8, 66_u8, 67_u8}.hash_tree_root.should eq(root)
      "ABC".hash_tree_root.should eq(root)
    end
  end

  describe "StaticArray(T, N)#hash_tree_root" do
    it "should return hash_tree_root" do
      root = Bytes[65, 66, 67].resize(SSZ::BYTES_PER_CHUNK, 0_u8)
      arr = UInt8.static_array(65_u8, 66_u8, 67_u8)
      arr.hash_tree_root.should eq(root)
    end
  end

  describe "Union#hash_tree_root" do
    it "should return hash_tree_root" do
      Union3.hash_tree_root(nil).should eq(Bytes[254, 10, 54, 214, 62, 119, 88, 168, 129, 92, 6, 37, 52, 17, 131, 163, 250, 210, 211, 93, 86, 74, 152, 113, 227, 111, 1, 11, 156, 43, 208, 107])
      Union3.hash_tree_root(33_i32).should eq(Bytes[101, 191, 238, 175, 17, 128, 244, 240, 204, 179, 2, 241, 226, 203, 65, 144, 113, 80, 234, 151, 38, 25, 211, 23, 38, 136, 235, 54, 54, 238, 160, 176])
    end
  end

  describe "Serializable#hash_tree_root" do
    it "should return hash_tree_root" do
      p = Point.new(10, 20)
      p.hash_tree_root.should eq(Bytes[233, 51, 56, 208, 41, 214, 210, 185, 245, 221, 127, 13, 242, 90, 161, 123, 155, 187, 12, 132, 77, 186, 7, 159, 138, 116, 174, 187, 11, 41, 111, 153])
    end
  end
end
