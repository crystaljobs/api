require "pg"
require "migrate"

require "atom/env"
require "atom/logger"

runtime_env DATABASE_URL

desc "Migrate Database to the latest version"
task :dbmigrate do
  migrator = Migrate::Migrator.new(
    DB.open(ENV["DATABASE_URL"]),
    Atom.logger,
  )
  migrator.to_latest
end

desc "Reset database to zero and then to the latest version"
task :dbredo do
  migrator = Migrate::Migrator.new(
    DB.open(ENV["DATABASE_URL"]),
    Atom.logger,
  )
  migrator.redo
end
