require "./codec"
require "./constants"
require "./merkleization"

struct Nil
  def hash_tree_root : Bytes
    SSZ::EMPTY_CHUNK
  end
end

struct Bool
  TRUE_HASH_TREE_ROOT = Bytes.new(SSZ::BYTES_PER_CHUNK) { |i| i == 0 ? 1_u8 : 0_u8 }

  def hash_tree_root : Bytes
    self ? TRUE_HASH_TREE_ROOT : SSZ::EMPTY_CHUNK
  end
end

struct Number
  def hash_tree_root : Bytes
    SSZ.bitwise_merkleize(SSZ.pack([ssz_encode]), 1)
  end
end

struct Enum
  def hash_tree_root : Bytes
    SSZ.bitwise_merkleize(SSZ.pack([ssz_encode]), 1)
  end
end

struct Char
  def hash_tree_root : Bytes
    SSZ.bitwise_merkleize(SSZ.pack([ssz_encode]), 1)
  end
end

class String
  def hash_tree_root : Bytes
    merkle_root = SSZ.bitwise_merkleize(SSZ.pack([ssz_encode]), 0)
    SSZ.mix_in_length(merkle_root, size.ssz_encode.resize(SSZ::BYTES_PER_CHUNK, 0_u8))
  end
end

module Enumerable(T)
  def hash_tree_root : Bytes
    chunks = if T.ssz_basic?
      SSZ.pack([ssz_encode])
    else
      {% if T.union? %}
        map { |element| T.hash_tree_root(element) }.to
      {% else %}
        map(&.hash_tree_root).to_a
      {% end %}
    end
    merkle_root = SSZ.bitwise_merkleize(chunks, 0_u64)
    SSZ.mix_in_length(merkle_root, size.ssz_encode.resize(SSZ::BYTES_PER_CHUNK, 0_u8))
  end
end

struct StaticArray(T, N)
  def hash_tree_root : Bytes
    if T.ssz_basic?
      SSZ.bitwise_merkleize(SSZ.pack([ssz_encode]), 1)
    else
      chunks = Array(Bytes).new
      {% if T.union? %}
        chunks = map { |element| T.hash_tree_root(element) }.to_a
      {% else %}
        chunks = map(&.hash_tree_root).to_a
      {% end %}
      SSZ.bitwise_merkleize(chunks, size.to_u64)
    end
  end
end

struct Union
  def self.hash_tree_root(value : self) : Bytes
    type_index = ssz_type_index(value)
    merkle_root = SSZ.bitwise_merkleize(SSZ.pack([value.ssz_encode]), 0)
    SSZ.mix_in_type(merkle_root, type_index.ssz_encode.resize(SSZ::BYTES_PER_CHUNK, 0_u8))
  end
end

module SSZ
  module Serializable
    def hash_tree_root : Bytes
      {% if @type.instance_vars.empty? %}
        SSZ::EMPTY_CHUNK
      {% else %}
        num_ivars = {{@type.instance_vars.size}}
        chunks = Array(Bytes).new(initial_capacity: num_ivars)
        {% for ivar in @type.instance_vars %}
          {% unless ivar.annotation(::SSZ::Ignored) %}
            {% if ivar.type.union? %}
              chunks.push({{ivar.type.name}}.hash_tree_root(@{{ivar.name}}))
            {% else %}
              chunks.push(@{{ivar.name}}.hash_tree_root)
            {% end %}
          {% end %}
        {% end %}
        SSZ.bitwise_merkleize(chunks, chunks.size.to_u64)
      {% end %}
    end
  end
end
