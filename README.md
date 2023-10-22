# Ruby Job Concurrency

<span>[![Gem Version](https://img.shields.io/gem/v/job-concurrency.svg?label=job-concurrency&colorA=D30001&colorB=DF3B3C)](https://rubygems.org/gems/job-concurrency)</span> <span>
[![ruby](https://img.shields.io/badge/ruby-2.6+-ruby.svg?colorA=D30001&colorB=DF3B3C)](https://github.com/andrewdsilva/cakemail-ruby)</span> <span>
[![MIT license](https://img.shields.io/badge/license-MIT-mit.svg?colorA=1f7a1f&colorB=2aa22a)](http://opensource.org/licenses/MIT)</span> <span>
![Downloads](https://img.shields.io/gem/dt/job-concurrency.svg?colorA=004d99&colorB=0073e6)</span>

The purpose of this little library is to make it easy to manage job concurrency and set a limit on how fast they can happen.

If you want to control how many jobs can be executed at the same time or how many can occur in a minute, this gem can help you.

## Installation

To install the gem add it into a Gemfile (Bundler):

```ruby
gem "job-concurrency"
```

And then execute:

```
bundle install
```

## Features

- Rate limiting
- Concurrency control
- Queue management

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
