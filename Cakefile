require "pg"
require "migrate"

require "./src/env"
require "./src/utils/custom_log_formatter"

runtime_env DATABASE_URL

desc "Migrate Database to the latest version"
task :dbmigrate do
  migrator = Migrate::Migrator.new(
    DB.open(ENV["DATABASE_URL"]),
    Logger.new(STDOUT, formatter: custom_log_formatter)
  )
  migrator.to_latest
end

desc "Reset database to zero and then to the latest version"
task :dbredo do
  migrator = Migrate::Migrator.new(
    DB.open(ENV["DATABASE_URL"]),
    Logger.new(STDOUT, formatter: custom_log_formatter)
  )
  migrator.redo
end
