require "bundler/gem_tasks"
require './config/environment'

task default: :test

desc 'Run all tests by default'
task :test => 'db:environment' do
  exec('bundle exec ruby -Ilib -Itest -Ilib/models test/news_test.rb')
end

namespace :db do
  task :environment => :dotenv do
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate MIGRATIONS_DIR, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end
end
