source "http://rubygems.org/"

gem 'sinatra'
gem 'erubis'
gem 'data_mapper'
gem 'dm-sqlite-adapter'

group :development, :test do
  gem 'thin'
end


if ENV['MAC_TEST_GEMS']
  group :development, :test do
    gem 'ZenTest', '~> 4.5.0'
    gem 'autotest-growl'
    gem 'autotest-fsevent'
  end
end