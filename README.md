# konfig-yaml for Ruby

[![Gem Version](https://badge.fury.io/rb/konfig-yaml.svg)](https://badge.fury.io/rb/konfig-yaml)
[![Build Status](https://travis-ci.org/tilfin/konfig-yaml-rb.svg?branch=master)](https://travis-ci.org/tilfin/konfig-yaml-rb)
[![Code Climate](https://codeclimate.com/github/tilfin/konfig-yaml-rb/badges/gpa.svg)](https://codeclimate.com/github/tilfin/konfig-yaml-rb)
[![Test Coverage](https://codeclimate.com/github/tilfin/konfig-yaml-rb/badges/coverage.svg)](https://codeclimate.com/github/tilfin/konfig-yaml-rb/coverage)

The loader of YAML configuration for each execution environments like [settingslogic](https://github.com/settingslogic/settingslogic).

- Expand environment variables like bash (ex. `storage-${RUBY_ENV}`)
    - If an environment variable is not set, it is to be emtpy string.
    - If `${DB_USER:-user}` or `${DB_USER:user}` is defined, `user` is expanded unless DB_USER does not exists.
- Deep merge the environment settings and default settings (except array items)
- Support YAML Anchor `&something` / Reference `<<: *something`
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

### Load a configuration instance

```ruby
require 'konfig-yaml'

config = KonfigYaml.new([name], [opts]);
```

* `name` specifys the name of `config/<name>.yml` ( default `app` )
* `opts`
  * `:path` config directory path resolved from the process current one ( default `config` )
  * `:erb` whether expand ERB or not ( default `false` )
  * `:env` Execution environment ( default **RUBY_ENV** value, **RAILS_ENV** value, **RACK_ENV** value, or `development` )
  * `:use_cache` whether using cache ( default `true` )

### Load a configuration as Static class

```ruby
require 'konfig-yaml'

KonfigYaml.setup do |config|
  config.const_name = 'Config' # default is 'Settings'
end

p Config.log.level
```

### Access the values

#### by accessor method

```ruby
port = config.port
log_lv = config.log.level
```

#### by symbol key

```ruby
port = config[:port]
log_lv = config.log[:level]
```

#### by string key

```ruby
port = config['port']
log_lv = config['log'].level
```

### Dynamically change settings

Support only symbol or string key if adding new field

```ruby
config[:port] = 80
config.log['level'] = 'fatal'
config[:backend] = { host: 'cms.example.com', "port" => 7080 }

p config.port         # 80
p config.log.level    # "fatal"
p config.backend.host # "cms.example.com"
p config.backend.port # 7080
```

### Clear caches

For testing purpose

```
KonfigYaml.clear
```

## Example

### Setup

#### config/app.yml

```
default:
  port: 8080
  log:
    level: info
  db:
    name: ${BRAND:-normal}-app-${RUBY_ENV}
    user: user
    pass: pass

production:
  port: 1080
  log:
    level: error
  db:
    pass: Password
```

#### main.rb

```
require 'konfig-yaml'

config = KonfigYaml.new

puts config.port
puts config.log.level
puts config.db.user
puts config[:db]['name']
puts config['db'].password
```

### Run

#### In development

```
$ RUBY_ENV=development ruby main.rb
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
