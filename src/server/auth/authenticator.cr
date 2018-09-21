require "jwt"

runtime_env JWT_SECRET_KEY, DOMAIN

module Server::Auth
  class Authenticator
    include Prism::Authenticator

    getter! dev : Developer?

    def initialize(@token : String, @logger : Logger)
    end

    def authenticate
      return self if dev?

      payload, header = JWT.decode(@token, ENV["JWT_SECRET_KEY"], "HS256", iss: ENV["DOMAIN"], sub: "devAuth")

      begin
        about = uninitialized String
        github_id = uninitialized Int32
        github_username = uninitialized String
        github_access_token = uninitialized String

        @dev = Developer.new(
          id: payload["dev"].as_h["id"].as_i,
          about: about,
          github_id: github_id,
          github_username: github_username,
          github_access_token: github_access_token,
        )
      rescue ex : JSON::Error | TypeCastError | ArgumentError
        @logger.debug("Mailformed JWT: #{ex}")
        nil
      end
    rescue ex : JWT::Error
      @logger.debug("Authentication failure: #{ex}")
      nil
    end
  end
end
