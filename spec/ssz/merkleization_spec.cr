require "../spec_helper"

describe SSZ do
  describe "#bitwise_merkleize" do
    it "should merkleize input" do
      chunks = [
        Bytes[10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        Bytes[20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        Bytes[30, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]
      SSZ.bitwise_merkleize(chunks, 1).should eq(Bytes[171, 203, 11, 89, 250, 140, 167, 94, 118, 47, 105, 71, 123, 246, 173, 81, 160, 66, 173, 119, 200, 235, 51, 221, 155, 179, 198, 15, 237, 90, 241, 148])
    end
  end

  describe "#merge_chunks" do
    it "merges chunks" do
      layers = [
        Bytes[10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        Bytes.empty
      ]
      current_root = Bytes[20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      layers, current_root = SSZ.merge_chunks(layers, current_root, 1, 2, 1)

      layers.should eq([
        Bytes[10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        Bytes[233, 51, 56, 208, 41, 214, 210, 185, 245, 221, 127, 13, 242, 90, 161, 123, 155, 187, 12, 132, 77, 186, 7, 159, 138, 116, 174, 187, 11, 41, 111, 153]
      ])
    end
  end

  describe "#pack" do
    it "should pack serialized objects to chunks" do
      SSZ.pack([] of Bytes).should eq([SSZ::EMPTY_CHUNK] of Bytes)
      SSZ.pack([Bytes.empty, Bytes.empty]).should eq([SSZ::EMPTY_CHUNK] of Bytes)

      bytes1 = Bytes.new(SSZ::BYTES_PER_CHUNK) { Random.rand(UInt8::MAX).to_u8 }
      SSZ.pack([bytes1]).should eq([bytes1])

      bytes2 = Bytes[10, 0, 0, 0]
      bytes3 = Bytes[20, 0, 0, 0, 0, 0, 0, 0]
      SSZ.pack([bytes2, bytes3]).should eq([Bytes[10, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]])

      bytes4 = Bytes.new(SSZ::BYTES_PER_CHUNK) { |i| (i + 12_u8).to_u8 }
      SSZ.pack([bytes2, bytes3, bytes4]).should eq([
        Bytes[10, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
        Bytes[32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      ])
    end
  end

  describe "#bit_length" do
    it "should calc bit length" do
      SSZ.bit_length(0).should eq(0_u64)
      SSZ.bit_length(1).should eq(1_u64)
      SSZ.bit_length(6).should eq(3_u64)
      SSZ.bit_length(32).should eq(6_u64)
      SSZ.bit_length(128).should eq(8_u64)
    end
  end

  describe "#mix_in_length" do
    it "should calc mix_in_length" do
      root = Bytes[4, 234, 9, 20, 130, 65, 136, 252, 189, 213, 75, 94, 39, 65, 12, 48, 182, 5, 32, 136, 121, 240, 72, 147, 73, 231, 255, 64, 206, 156, 26, 208]
      length = Bytes[4, 0, 0, 0]
      SSZ.mix_in_length(root, length).should eq(Bytes[223, 1, 198, 179, 145, 121, 250, 18, 9, 25, 177, 236, 235, 203, 122, 247, 60, 112, 107, 151, 155, 148, 88, 80, 111, 140, 49, 200, 189, 180, 55, 158])
    end
  end
end
