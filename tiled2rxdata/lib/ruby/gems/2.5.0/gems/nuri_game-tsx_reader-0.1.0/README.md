# NuriGame::TsxReader

TSXReader that convert .tsx files to a ruby object

## Note

Currently the following feature of tileset aren't supported :
* animation
* wangsets
* grid
* tile

(I don't even know how some works and I couldn't understand so you're free to help for that ^^')

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nuri_game-tsx_reader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nuri_game-tsx_reader

## Usage

```ruby
require 'nuri_game/tsx_reader'

# [...]

tileset = NuriGame::TsxReader.new('tilesetname.tsx')
# access here to tileset properties (see doc)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests at https://gitlab.com/NuriYuri/nuri_game-tsx_reader.
