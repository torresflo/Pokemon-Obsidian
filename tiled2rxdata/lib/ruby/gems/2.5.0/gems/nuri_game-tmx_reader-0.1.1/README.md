# NuriGame::TmxReader

TMXReader that convert .tmx files to a ruby object

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nuri_game-tmx_reader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nuri_game-tmx_reader

## Usage

```ruby
require 'nuri_game/tmx_reader'

# [...]

map = NuriGame::TmxReader.new('mapname.tmx')
# access here to map.layers, map.tilesets, map.width, map.height, map.tilewidth or map.tileheight
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome at https://gitlab.com/NuriYuri/nuri_game-tmx_reader.
