require "../spec_helper"

describe Slice do
  describe "#+" do
    it "should return clone of self" do
      a = Bytes[1, 2]
      b = Bytes.empty
      c = a + b
      c.should eq(a)

      # `c` must be a copy, not a reference
      c[0] = 3
      c.should eq(Bytes[3, 2])
      a.should eq(Bytes[1, 2])
    end

    it "should concatenate slices" do
      a = Bytes[1, 2]
      b = Bytes[3, 4]
      c = a + b
      c.should eq(Bytes[1, 2, 3, 4])
    end
  end
end
