require "prism"
require "http/server/handlers/error_handler"

require "./env"
require "./services/logger"
require "./models"
require "./server/*"

runtime_env HOST, PORT

require "./utils/custom_log_formatter"

log_handler = Prism::LogHandler.new(logger)
error_handler = HTTP::ErrorHandler.new(true)
cors = Prism::CORS.new(allow_headers: %w(accept content-type authorization))
auth_handler = Server::Auth::Handler.new(logger)
router = Server::Router.new
handlers = [log_handler, error_handler, cors, auth_handler, router]

server = Prism::Server.new(handlers, logger)
server.bind_tcp(ENV["HOST"], ENV["PORT"].to_i, true)
server.listen
