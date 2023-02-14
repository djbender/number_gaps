source 'https://rubygems.org'
ruby '3.2.1'

gem 'sinatra', '~> 3.0.5'
gem 'sinatra-contrib', '~> 3.0.5'

group :production do
  gem 'puma', '~> 6.1.0', require: false
end

group :development, :test do
  gem 'byebug'
end

group :development do
  gem 'foreman', require: false
  gem 'webrick', require: false
end
