require "random/secure"
require "../../../../services/redis"
require "../../../../lib/github/api/client"

runtime_env GITHUB_CLIENT_ID, GITHUB_CALLBACK_URL

module Server::Actions
  struct OAuth::GitHub::Init
    include Prism::Action

    OAUTH_URL_TEMPLATE = "https://github.com/login/oauth/authorize?allow_signup=false&client_id=%{client_id}&redirect_uri=%{redirect_uri}&state=%{state}"
    REDIRECT_URI       = URI.escape(ENV["GITHUB_CALLBACK_URL"])
    STATE_EXPIRES_IN   = 30.minutes.to_i

    def call
      state = Random::Secure.hex

      key = "oauth:github:state:#{state}"
      redis.set(key, true)
      redis.expire(key, STATE_EXPIRES_IN)

      redirect(OAUTH_URL_TEMPLATE % {
        client_id:    ENV["GITHUB_CLIENT_ID"],
        redirect_uri: REDIRECT_URI,
        state:        state,
      })
    end
  end
end
