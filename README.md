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
- Int8
- UInt8
- Int16
- UInt16
- Int32
- UInt32
- Int64
- UInt64
- Int128
- UInt128
- Float32
- Float64
- BigDecimal
- BigFloat
- BigInt
- BigRational
- Complex - serialize as pair of `Float64` (*real* and *imag*)
- Enum - supports underlying types
- Char - Unicode 4 bytes
- String - supports Unicode
- Union(T) - where `T` is supported type
- Array(T) - where `T` is supported type
- Deque(T) - where `T` is supported type
- StaticArray(T) - where `T` is supported type
- Slice(T) - where `T` is supported type
- Set(T) - where `T` is supported type
- Range(B, E) - where `B` and `E` are supported types
- Time - serialize as `Int64` UTC timestamp
- Time::Span - serialize as pair of `Int64` (*seconds*) and `Int32` (*nanoseconds*)
- URI - serialize as `String`
- UUID - serialize as `String`
- SemanticVersion - serialize as `String`
- SemanticVersion::Prerelease - serialize as `String`
- Class and Struct which includes `SSZ::Serializable` see example above

## Contributing

1. Fork it (<https://github.com/light-side-software/ssz.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Tamás Szekeres](https://github.com/TamasSzekeres) - creator and maintainer
