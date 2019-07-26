enum Color
  Red
  Green
  Blue
end

enum Direction : UInt8
  None  = 0

  Left  = 10
  Up    = 11
  Right = 12
  Down  = 13
end

alias Union1 = Bool | UInt16 | Int32
alias Union2 = (UInt8 | String)?
alias Union3 = (Bool | Int32 | Nil | UInt32)

# Simple struct
struct Point
  include SSZ::Serializable

  property x : Int32 = 0
  property y : Int32 = 0

  def initialize(@x : Int32 = 0, @y : Int32 = 0)
  end
end

module DbEntry
  property id : UInt64
end

class Person
  include SSZ::Serializable

  property name : String = ""
  property age : UInt16 = 0_u16

  def initialize(@name : String, @age : UInt16)
  end

  def ==(other : Person) : Bool
    (@name == other.name) && (@age == other.age)
  end
end

# Inherited
class Employee < Person
  include SSZ::Serializable

  property company : String = ""

  @[SSZ::Ignored]
  property calculated : Int32 = 0

  def initialize(@name : String, @age : UInt16, @company : String)
    @calculated = @name.size + @age + @company.size
  end

  def ==(other : Employee) : Bool
    (@name == other.name) && (@age == other.age) && (@company == other.company)
  end
end

struct StructWithUnions
  include SSZ::Serializable

  property a : UInt8 = 0_u8
  property b : Union3 = nil
  property c : Char = 'A'
  property d : Union3 = false

  def initialize(@a : UInt8, @b : Union3, @c : Char, @d : Union3)
  end

  def ==(other : self) : Bool
    (@a == other.a) && (@b == other.b) && (@c == other.c) && (@d == other.d)
  end
end
