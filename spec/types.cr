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
