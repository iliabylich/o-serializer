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
            #to_hash    13.173k i/100ms
       O::Serializer     4.652k i/100ms
                 AMS   342.000  i/100ms
Calculating -------------------------------------
            #to_hash    140.705k (±13.4%) i/s -    698.169k in   5.072368s
       O::Serializer     45.944k (±14.8%) i/s -    227.948k in   5.105587s
                 AMS      3.368k (±15.1%) i/s -     16.416k in   5.016766s

Comparison:
            #to_hash:   140705.3 i/s
       O::Serializer:    45943.8 i/s - 3.06x  slower
                 AMS:     3368.5 i/s - 41.77x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/o-serializer.
