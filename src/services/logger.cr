require "logger"
require "../utils/custom_log_formatter"

class Services::Logger
  class_getter instance = ::Logger.new(STDOUT, ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG, formatter: custom_log_formatter)
end

def logger
  Services::Logger.instance
end
