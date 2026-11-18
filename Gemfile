source 'https://rubygems.org'
ruby '>= 3.2'

gem 'bcrypt', '~> 3.1', '>= 3.1.22'
gem 'sequel', '~> 5.110'
gem 'sinatra', '~> 4.2', '>= 4.2.2'
gem 'rack', '~> 3.2', '>= 3.2.8'
gem 'rack-session', '~> 2.1', '>= 2.1.2'
gem 'rackup', '~> 2.3'
gem 'webrick', '~> 1.9', '>= 1.9.2'
gem 'rake', '~> 13.3'

platforms :jruby do
  gem 'jdbc-postgres', '~> 42.7', '>= 42.7.11'
end
platforms :mri do
  gem 'pg', '~> 1.7'
end

group :test do
  gem 'rspec', '~> 3.13'
  gem 'capybara', '~> 3.40'
  gem 'rack-test', '~> 2.3'
  platforms(:jruby) { gem 'jdbc-sqlite3', '~> 3.46' }
  platforms(:mri) { gem 'sqlite3', '~> 2.8' }
end
