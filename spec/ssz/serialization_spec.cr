require "../spec_helper"

describe SSZ do
  describe SSZ::Serializable do
    describe Point do
      p = Point.new(13, 62)

      it "should return true" do
        Point.ssz_variable?.should be_false
        p.ssz_variable?.should be_false
      end

      it "should return false" do
        Point.ssz_fixed?.should be_true
        p.ssz_fixed?.should be_true
      end

      it "should return size" do
        p.ssz_size.should eq(8)
      end

      it "should serialize Point" do
        bytes = p.ssz_encode
        bytes.should eq(Bytes[13, 0, 0, 0, 62, 0, 0, 0])

        io = IO::Memory.new(bytes)
        Point.ssz_decode(io).should eq(p)
        io.pos.should eq(8)
        Point.ssz_decode(bytes).should eq(p)
      end
    end

    describe Person do
      person = Person.new("John", 45)

      it "should return true" do
        Person.ssz_variable?.should be_true
        person.ssz_variable?.should be_true
      end

      it "should return false" do
        Person.ssz_fixed?.should be_false
        person.ssz_fixed?.should be_false
      end

      it "should return size" do
        person.ssz_size.should eq(10)
      end

      it "should serialize Person" do
        bytes = person.ssz_encode
        bytes.should eq(Bytes[6, 0, 0, 0, 45, 0, 74, 111, 104, 110])

        io = IO::Memory.new(bytes)
        Person.ssz_decode(io).should eq(person)
        io.pos.should eq(10)
        Person.ssz_decode(bytes).should eq(person)
      end
    end

    # Tesing inheritance & `SSZ::Ignore` attribute
    describe Employee do
      employee = Employee.new("James", 32, "DEV Inc.")

      it "should return true" do
        Employee.ssz_variable?.should be_true
        employee.ssz_variable?.should be_true
      end

      it "should return false" do
        Employee.ssz_fixed?.should be_false
        employee.ssz_fixed?.should be_false
      end

      it "should return size" do
        employee.ssz_size.should eq(23)
      end

      it "should serialize Employee" do
        employee.calculated.should eq(45)
        bytes = employee.ssz_encode
        bytes.should eq(Bytes[10, 0, 0, 0, 32, 0, 15, 0, 0, 0, 74, 97, 109, 101, 115, 68, 69, 86, 32, 73, 110, 99, 46])

        io = IO::Memory.new(bytes)
        decoded = Employee.ssz_decode(io)
        decoded.should eq(employee)
        decoded.calculated.should eq(0)
        io.pos.should eq(23)
        Employee.ssz_decode(bytes).should eq(employee)
      end
    end

    describe StructWithUnions do
      s = StructWithUnions.new(12_u8, nil, 'B', 45_i32)

      it "should return true" do
        StructWithUnions.ssz_variable?.should be_true
        s.ssz_variable?.should be_true
      end

      it "should return false" do
        StructWithUnions.ssz_fixed?.should be_false
        s.ssz_fixed?.should be_false
      end

      it "should return size" do
        s.ssz_size.should eq(25)
      end

      it "should serialize StructWithUnions" do
        bytes = s.ssz_encode
        bytes.should eq(Bytes[12, 13, 0, 0, 0, 66, 0, 0, 0, 17, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 45, 0, 0, 0])

        io = IO::Memory.new(bytes)
        decoded = StructWithUnions.ssz_decode(io)
        decoded.should eq(s)
        io.pos.should eq(25)
        StructWithUnions.ssz_decode(bytes).should eq(s)
      end
    end
  end
end
