require "../spec_helper"

describe SSZ do
  describe "ZERO_HASHES" do
    it "checks zero-hashes" do
      SSZ::ZERO_HASHES.size.should eq(SSZ::NUM_ZERO_HASHES)
      SSZ::ZERO_HASHES[0].should eq(Bytes[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      SSZ::ZERO_HASHES[1].should eq(Bytes[245, 165, 253, 66, 209, 106, 32, 48, 39, 152, 239, 110, 211, 9, 151, 155, 67, 0, 61, 35, 32, 217, 240, 232, 234, 152, 49, 169, 39, 89, 251, 75])
      SSZ::ZERO_HASHES[SSZ::NUM_ZERO_HASHES - 1].should eq(Bytes[175, 162, 199, 93, 194, 197, 168, 70, 44, 23, 9, 46, 225, 239, 226, 29, 233, 177, 15, 13, 192, 222, 160, 121, 79, 48, 69, 19, 225, 170, 51, 210])
    end
  end
end
