require "./constants"

module SSZ
  # Given ordered `SSZ::BYTES_PER_CHUNK`-byte chunks, if necessary utilize zero chunks so that the
  # number of chunks is a power of two, *Merkleize* the chunks, and return the root.
  # Note that merkleize on a single chunk is simply that chunk, i.e. the identity
  # when the number of chunks is one.
  def self.bitwise_merkleize(chunks : Array(Bytes), padding : UInt64) : Bytes
    count = chunks.size.to_u64
    depth = bit_length(0).to_u64
    if bit_length(count - 1) > depth
      depth = bit_length(count - 1)
    end
    max_depth = depth
    if bit_length(padding - 1) > max_depth
      max_depth = bit_length(padding - 1)
    end
    layers = Array(Bytes).new(size: max_depth + 1, value: Bytes.empty)

    chunks.each_with_index do |chunk, i|
      layers, _ = merge_chunks(layers, chunk, i.to_u64, count, depth)
    end

    if (1 << depth) != count
      layers, zh0 = merge_chunks(layers, SSZ::ZERO_HASHES[0], count, count, depth)
    end

    (depth...max_depth).each do |i|
      res = SSZ.hash(layers[i] + SSZ::ZERO_HASHES[i])
      layers[i + 1] = res
    end

	  layers[max_depth].resize(32, 0_u8)
  end

  def self.merge_chunks(layers : Array(Bytes), current_root : Bytes, i, count, depth : UInt64)
    j = 0_u64
    res = Bytes.empty

    loop do
      if i & (1 << j) == 0
        if (i == count) && (j < depth)
          res = SSZ.hash(current_root + SSZ::ZERO_HASHES[j])
          current_root = res
        else
          break
        end
      else
        res = hash(layers[j] + current_root)
        current_root = res
      end
      j += 1
    end
    layers[j] = current_root
    {layers, current_root}
  end

  # Packs SSZ-encoded objects into `SSZ::BYTES_PER_CHUNK`-byte chunks,
  # right-pad the last chunk with zero bytes, and return the chunks.
  def self.pack(serialized_items : Enumerable(Bytes)) : Array(Bytes)
    size = serialized_items.sum(&.size)

    # If there are no items, we return an empty chunk.
    if (serialized_items.size == 0) || (size == 0)
      return [SSZ::EMPTY_CHUNK]
    end

    # If each item has exactly BYTES_PER_CHUNK length, we return the list of serialized items.
    return serialized_items if serialized_items.all? { |item| item.size == SSZ::BYTES_PER_CHUNK }

    num_chunks = (size / SSZ::BYTES_PER_CHUNK)
    num_chunks += 1 if (size % SSZ::BYTES_PER_CHUNK) > 0

    chunks = Array.new(size: num_chunks) { SSZ::EMPTY_CHUNK.dup }

    chunk_i, byte_i = 0, 0
    serialized_items.each do |item|
      item.each do |byte|
        chunks[chunk_i][byte_i] = byte
        byte_i = (byte_i + 1) % SSZ::BYTES_PER_CHUNK
        chunk_i += 1 if byte_i == 0
      end
    end

    chunks
  end

  def self.bit_length(n : Int) : UInt64
    return 0_u64 if n == 0
    Math.log2(n.to_f64).to_u64 + 1_u64
  end

  # Retuns Merkle root of given **root** and a **length** (`UInt256` little-endian serialization)
  def self.mix_in_length(root : Bytes, length : Bytes) : Bytes
    raise "`root` must be 32-byte length" if root.size != 32
    hash(root + length)
  end

  def self.mix_in_type(root : Bytes, type_index : Bytes) : Bytes
    raise "`root` must be 32-byte length" if root.size != 32
    mix_in_length(root, type_index)
  end
end
