require 'sequel'
require_relative 'app/models/connection'
Sequel.extension :migration

namespace :db do
  desc 'Create missing tables without dropping or changing existing tables'
  task :migrate do
    Sequel::Migrator.run(DB, File.join(__dir__, 'db/migrations'))
  end
  task auto_upgrade: :migrate
end
