require "./access_token"

module GitHub
  class Client
    def initialize(@client_id : String, @client_secret : String)
      @client = HTTP::Client.new(URI.parse("https://github.com"))
    end

    def get_access_token(code : String, state : String)
      response = @client.post("/login/oauth/access_token",
        headers: HTTP::Headers{
          "Accept"       => "application/json",
          "Content-Type" => "application/json",
        },
        body: {
          client_id:     @client_id,
          client_secret: @client_secret,
          code:          code,
          state:         state,
        }.to_json)

      if response.status_code == 200
        AccessToken.from_json(response.body)
      else
        raise "Got a #{response.status_code} response from GitHub: #{response.body}"
      end
    end
  end
end
