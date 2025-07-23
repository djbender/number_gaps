source 'https://rubygems.org'

ruby file: '.ruby-version' 

gem 'sinatra', '~> 3.0.5'
gem 'sinatra-contrib', '~> 3.0.5'
gem "logger", "~> 1.7" # fix rack warning for ruby 3.5
gem 'csv', '~> 3.3'
# for rack warning regarding omission in ruby 3.5
gem "ostruct", "~> 0.6.3"

group :production do
  gem 'puma', '~> 5.6.4', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'irb', '~> 1.15'
end

group :development do
  gem 'foreman', require: false
  gem 'webrick', require: false
end
