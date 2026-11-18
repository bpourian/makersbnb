ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite::memory:' : 'sqlite::memory:'
require_relative '../app/models/connection'
Sequel.extension :migration
Sequel::Migrator.run(DB, File.expand_path('../db/migrations', __dir__))
require 'capybara/rspec'
require_relative '../app/app'
require_relative 'helpers/helpers'
Capybara.app = MakersBnb
RSpec.configure do |config|
  config.include Helpers
  config.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
