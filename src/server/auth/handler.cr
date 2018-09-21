require "./authenticator"

module Server::Auth
  class Handler
    def self.new(logger)
      Prism::ProcHandler.new do |handler, context|
        if token = context.request.headers["Authorization"]?.try &.[/Token ([\w.\.-]+)/, 1]?
          context.request.auth = Authenticator.new(token, logger)
        end

        handler.call_next(context)
      end
    end
  end
end
