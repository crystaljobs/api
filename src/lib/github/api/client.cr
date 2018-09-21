require "./user"

module GitHub::API
  class Client
    property access_token : String? = nil

    def initialize
      @client = HTTP::Client.new(URI.parse("https://api.github.com"))
    end

    def get_user(username : String)
      response = @client.get("/user/#{username}")
      if response.status_code == 200
        User.from_json(JSON.parse(response.body.not_nil!.gets_to_end))
      end
    end

    def get_authenticated_user
      response = @client.get("/user", headers: HTTP::Headers{
        "Authorization" => "token #{@access_token.not_nil!}",
      })
      User.from_json(response.body)
    end
  end
end
