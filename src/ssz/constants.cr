module SSZ
  BYTES_PER_CHUNK         = 32 # Number of bytes per chunk.
  BYTES_PER_LENGTH_OFFSET =  4 # Number of bytes per serialized length offset.
  BITS_PER_BYTE           =  8 # Number of bits per byte.

  {% if BYTES_PER_LENGTH_OFFSET == 4 %}
  alias Offset = Int32
  {% elsif BYTES_PER_LENGTH_OFFSET == 2 %}
  alias Offset = Int16
  {% elsif BYTES_PER_LENGTH_OFFSET == 1 %}
  alias Offset = Int8
  {% end %}
end
