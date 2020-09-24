# insensitive_hash

[![Build Status](https://travis-ci.org/BoxFactura/insensitive_hash.svg?branch=master)](https://travis-ci.org/BoxFactura/insensitive_hash)

Hash with case-insensitive, Symbol/String-indifferent key access.

> This project is a fork from [https://github.com/junegunn/insensitive_hash](https://github.com/junegunn/insensitive_hash) and it was made to continue its maintenance.

## Installation

```
gem install insensitive_hash
```

## Instantiation

### Hash#insensitive

```ruby
require 'insensitive_hash'

ih = {}.insensitive

ih = { :abc => 1, 'hello world' => true }.insensitive

ih['ABC']         # 1
ih[:Hello_World]  # true
```

### Without monkey-patching Hash

If you don't like to have Hash#insensitive method, `require 'insensitive_hash/minimal'`

```ruby
require 'insensitive_hash/minimal'

ih = InsensitiveHash.new
ih = InsensitiveHash.new(:default_value)
ih = InsensitiveHash.new { |ih, k| ih[k] = InsensitiveHash.new }

ih = InsensitiveHash[ 'abc' => 1, :def => 2 ]
ih = InsensitiveHash[ 'abc', 1, :def, 2 ]
ih = InsensitiveHash[ [['abc', 1], [:def, 2]] ]

ih = InsensitiveHash[ 'hello world' => true ]
```

### Revert to normal Hash

```ruby
h = ih.sensitive
h = ih.to_hash
```

## Basic usage

```ruby
ih = {:abc => 1, 'DEF' => 2}.insensitive

# Case-insensitive, Symbol/String-indifferent access.
ih['Abc']          # 1
ih[:ABC]           # 1
ih['abc']          # 1
ih[:abc]           # 1
ih.has_key?(:DeF)  # true

ih['ABC'] = 10

# keys and values
ih.keys            # ['DEF', 'ABC']
ih.values          # [2, 10]

# delete
ih.delete :Abc     # 10
ih.keys            # ['DEF']
```

## Inherited insensitivity

When an InsensitiveHash is built from another Hash,
descendant Hash values are recursively converted to be insensitive.

```ruby

ih = { 'kids' => { :hello => [ { :world => '!!!' } ] } }.insensitive
ih[:kids]['Hello'].first['WORLD']  # !!!

ih = {:one => [ [ [ { :a => { :b => { :c => 'd' } } } ] ] ]}.insensitive
ih['one'].first.first.first['A']['b'][:C]  # 'd'
```

However, once InsensitiveHash is initialized,
descendant Hashes (or Hashes in Arrays) are not automatically converted.

```ruby
ih = {}.insensitive
ih[:abc] = { :def => true }

ih['ABC']['DEF']     # nil
```

Simply build a new InsensitiveHash out of it if you need recursive conversion.

```ruby
ih2 = ih.insensitive
ih2['ABC']['DEF']    # true
```

### Example: Processing case-insensitive YAML input

```ruby
db = YAML.load(File.read 'database.yml').insensitive

# Access values however you like
db['Development']['ADAPTER']
db[:production][:adapter]
```

## Enabling key-clash detection (Safe mode)

```ruby
ih = InsensitiveHash.new
ih.safe = true

# Will raise InsensitiveHash::KeyClashError
h.merge!('hello world' => 1, :hello_world => 2)

# Disables key-clash detection
h.safe = false
h.merge!('hello world' => 1, :hello_world => 2)
h['Hello World']  # 2
```

## Contributing to insensitive_hash

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

- Copyright (c) 2013 Junegunn Choi.
- Copyright (c) 2018-2020 Box Factura

See LICENSE.txt for further details.
