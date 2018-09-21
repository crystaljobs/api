require "jwt"

runtime_env DOMAIN, JWT_SECRET_KEY

module Server::Auth
  class Tokenizer
    def initialize(@dev : Developer, @expires_in : Time::MonthSpan = 1.month)
    end

    def tokenize
      payload = {
        "iss" => ENV["DOMAIN"],
        "sub" => "devAuth",
        "exp" => (Time.now + @expires_in).epoch,
        "dev" => {
          "id" => @dev.id,
        },
      }

      JWT.encode(payload, ENV["JWT_SECRET_KEY"], "HS256")
    end
  end
end
