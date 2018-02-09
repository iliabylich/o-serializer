# O::Serializer

OO-based data serialization library

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'o-serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install o-serializer

## Usage

Every `O` object responds to `.call`, that's a convention.

1. Basic Usage

``` ruby
User = Struct.new(:email, :password)

UserSerializer = O::Serializer[
  email: O::Field[:email],
  password: O::Field[:password]
]

UserSerializer.call(User.new('one', 'two'))
# => { email: 'one', password: 'two' }
```

2. Shortcut `O::PlainFields`

``` ruby
UserSerializer = O::Serializer[
  **O::PlainFields[:email, :password]
]
# => exactly the same behavior, works through 'to_hash' method
```

3. Collections

``` ruby
ProfileSerializer = O::Serializer[
  name: O::Field[:name]
]

profiles = [...]

O::Many[ProfileSerializer].call(users)
# => [ { ... }, { ... }, ...]
```

`O::Many` can be use to define associations.

``` ruby
UserSerializer = O::Serializer[
  tags: O::Many[TagSerializer]
]
```

4. Keys transformation

``` ruby
require 'ostruct'

user = OpenStruct.new(
  :active? => true,
  __tags: [OpenStruct.new(value: 'tag1')]
)

TagSerializer = O::Serializer[**O::PlainFields[:value]]

UserSerializer = O::Serializer[
  is_active: O::Field[:active?],
  tags: O::From[:__tags, O::Many[TagSerializer]]
]

UserSerializer.call(user)
# => {:is_active=>true, :tags=>[{:value=>"tag1"}]}
```

## Benchmarks

See `benchmark/run.rb`

```
Warming up --------------------------------------
            #to_hash    12.722k i/100ms
       O::Serializer     4.425k i/100ms
                 AMS   330.000  i/100ms
        fast_jsonapi     4.323k i/100ms
Calculating -------------------------------------
            #to_hash    139.382k (± 6.5%) i/s -    699.710k in   5.042120s
       O::Serializer     46.346k (± 4.5%) i/s -    234.525k in   5.071141s
                 AMS      3.359k (± 3.3%) i/s -     16.830k in   5.015951s
        fast_jsonapi     44.541k (± 4.5%) i/s -    224.796k in   5.057236s

Comparison:
            #to_hash:   139381.5 i/s
       O::Serializer:    46346.3 i/s - 3.01x  slower
        fast_jsonapi:    44540.7 i/s - 3.13x  slower
                 AMS:     3359.0 i/s - 41.49x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/o-serializer.
