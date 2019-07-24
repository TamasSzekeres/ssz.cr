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
end
