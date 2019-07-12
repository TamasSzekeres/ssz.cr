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

struct Point
  include SSZ::Serializable

  property x : Int32
  property y : Int32

  def initialize(@x : Int32 = 0, @y : Int32 = 0)
  end
end
