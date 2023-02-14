source 'https://rubygems.org'
ruby '3.2.1'

gem 'sinatra', '~> 2.1.0'
gem 'sinatra-contrib', '~> 2.1.0'

group :production do
  gem 'puma', '~> 5.6.4', require: false
end

group :development, :test do
  gem 'byebug'
end

group :development do
  gem 'foreman', require: false
  gem 'webrick', require: false
end
