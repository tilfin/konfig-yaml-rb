# konfig-yaml for Ruby

[![Gem Version](https://badge.fury.io/rb/konfig-yaml.svg)](https://badge.fury.io/rb/konfig-yaml)
[![Build Status](https://travis-ci.org/tilfin/konfig-yaml-rb.svg?branch=master)](https://travis-ci.org/tilfin/konfig-yaml-rb)
[![Code Climate](https://codeclimate.com/github/tilfin/konfig-yaml-rb/badges/gpa.svg)](https://codeclimate.com/github/tilfin/konfig-yaml-rb)
[![Test Coverage](https://codeclimate.com/github/tilfin/konfig-yaml-rb/badges/coverage.svg)](https://codeclimate.com/github/tilfin/konfig-yaml-rb/coverage)

The loader of yaml base configuration for each run enviroments like [settingslogic](https://github.com/settingslogic/settingslogic).

- Expand environment variables (ex. `users-${NODE_ENV}`)
- Deep merge the environment settings and default settings (except array items)
- Ruby version of [konfig-yaml](https://github.com/tilfin/konfig-yaml)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'konfig-yaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install konfig-yaml

## Usage

```
require 'konfig-yaml'

config = KonfigYaml.new([name], [opts]);
```

* `name` specifys the name of `config/<name>.yml` ( default `app` )
* `opts`
  * `:path` config directory path resolved from the process current one ( default `config` )
  * `:env` Run environment ( default **RUBY_ENV** value, **RAILS_ENV** value, **RACK_ENV** value, or `development` )
  * `:use_cache` whether using cache ( default `true` )

#### Clear cache

```
KonfigYaml.clear
```

## Example

### Setup

#### config/app.yml

```
default:
  port: 8080
  logger:
    level: info
  db:
    name: ${BRAND}-app-${NODE_ENV}
    user: user
    pass: pass

production:
  port: 1080
  logger:
    level: error
  db:
    pass: Password
```

#### main.rb

```
require 'konfig-yaml'

config = KonfigYaml.new

puts config.port
puts config.logger.level
puts config.db.user
puts config[:db]['name']
puts config['db'].password
```

### Run

#### In development

```
$ RUBY_ENV=development BRAND=normal ruby main.rb
8080
info
normal-app-development
user
pass
```

#### In production

```
$ RUBY_ENV=production BRAND=awesome ruby main.rb
1080
error
awesome-app-production
user
Password
```

## License

  [MIT](LICENSE)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tilfin/konfig-yaml-rb.
