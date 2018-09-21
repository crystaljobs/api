require "core/repository"
require "core/logger/standard"
require "./logger"

runtime_env DATABASE_URL

class Services::Repository
  class_getter instance = Core::Repository.new(
    DB.open(ENV["DATABASE_URL"]),
    Core::Logger::Standard.new(logger, ::Logger::DEBUG),
  )
end

# Global repository instance
def repo
  Services::Repository.instance
end

repo.exec("SELECT 1")
