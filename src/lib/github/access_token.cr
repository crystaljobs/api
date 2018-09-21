require "json"

module GitHub
  struct AccessToken
    JSON.mapping(
      access_token: String,
      scope: Array(String) | String,
      token_type: String,
    )
  end
end
