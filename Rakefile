# frozen_string_literal: true

require 'rake/testtask'
require './init.rb'

task default: [:spec]

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task rubo: [:spec] do
  sh 'rubocop app.rb models/*.rb'
end

desc 'Run in development mode'
task :run do
  sh 'rerun -c "rackup -p 3000"'
end

namespace :db do
  Sequel.extension :migration

  desc 'Run migrations'
  task :migrate do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(DB, 'db/migrations')
  end

  desc 'Rollback database to specified target'
  # e.g. $ rake db:rollback[100]
  task :rollback, [:target] do |_, args|
    target = args[:target] ? args[:target] : 0
    puts "Rolling back database to #{target}"
    Sequel::Migrator.run(DB, 'db/migrations', target: target)
  end

  task :reset_seeds do
    DB[:schema_seeds].delete if DB.tables.include?(:schema_seeds)
    BaseAccount.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed do
    require 'sequel'
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(DB, 'db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]

  desc 'Perform migration reset (full rollback, migration, and reseed)'
  task reset: [:rollback, :migrate, :reseed]
end

namespace :crypto do
  desc 'Create sample cryptographic key for database'
  task :db_key do
    puts "DB_KEY: #{SecureDB.generate_key}"
  end

  desc 'Create sample token key for communication'
  task :token_key do
    puts "TOKEN_KEY: #{AuthToken.generate_key}"
  end

  desc 'Create sample private/public keypair for signed communication'
  task :signing_key do
    require 'rbnacl/libsodium'
    signing_key = RbNaCl::SigningKey.generate
    verify_key = signing_key.verify_key

    puts "SIGNING KEY: #{Base64.strict_encode64(signing_key)}"
    puts " VERIFY KEY: #{Base64.strict_encode64(verify_key)}"
  end
end
