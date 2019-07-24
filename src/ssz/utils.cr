struct Slice(T)
  # Concatenation. Returns a new `Slice(T)` built by concatenating `self` and *other*.
  # The type of the new slice is the same of the type of original slices.
  #
  # ```
  # Bytes[1, 2] + Bytes[2, 3] # => Bytes[1, 2, 2, 3]
  # ```
  def +(other : Slice(T)) : self
    return dup if other.empty?

    dst = Slice(T).new(size + other.size)
    copy_to(dst)
    other.copy_to(dst.to_unsafe + size, other.size)
    dst
  end

  # Resizes slice to `new_size`-size.
  # If new size if bigger than actual size sets new elemets to `value`.
  #
  # ```
  # Bytes[1, 2].resize(4, 0_u8) # => Bytes[1, 2, 0, 0]
  # Bytes[1, 2, 3, 4].resize(2, 0_u8) # => Bytes[1, 2]
  # ```
  def resize(new_size : Int32, value : T) : self
    case size <=> new_size
    when 1 then self[0...new_size]
    when -1 then self + Slice(T).new(new_size - size, value)
    else
      self
    end
  end
end
