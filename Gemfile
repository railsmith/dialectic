source 'http://rubygems.org'

# Declare your gem's dependencies in dialectic.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]
gem 'rubocop', '~> 0.37.2', require: false

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.6.0'
end

group :mongoid do
  gem 'mongoid', '~> 5.1.0'
  gem 'mongoid_rails_migrations'
end

group :active_record do
  gem 'mysql2'
end