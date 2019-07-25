# Simple Serialize (SSZ)

[![Build Status](https://travis-ci.org/light-side-software/ssz.cr.svg?branch=master)](https://travis-ci.org/light-side-software/ssz.cr.svg?branch=master)

This package implements simple serialize algorithm specified in official Ethereum 2.0 [spec](https://github.com/ethereum/eth2.0-specs/blob/master/specs/simple-serialize.md).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ssz:
       github: light-side-software/ssz.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "ssz"

class Person
  include SSZ::Serializable

  property name : String = ""
  property age : UInt16 = 0_u16

  def initialize(@name : String, @age : UInt16)
  end
end

person = Person.new("John", 32)
encoded = person.ssz_encode

decoded = Person.ssz_decode(encoded)
```

## Supported types

- Nil
- Bool
- Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64
- Enum - supports underlying type
- Char - Unicode 4 bytes
- String - supports Unicode
- Union(T) - where `T` is supported type
- Array(T) - where `T` is supported type
- StaticArray(T) - where `T` is supported type
- Slice(T) - where `T` is supported type
- Set(T) - where `T` is supported type
- Class and Struct which includes `SSZ::Serializable` see example above

## Contributing

1. Fork it (<https://github.com/light-side-software/ssz.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Tamás Szekeres](https://github.com/TamasSzekeres) - creator and maintainer
