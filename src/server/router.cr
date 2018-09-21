require "./auth"
require "./actions/**"

module Server
  class Router
    def self.new
      Prism::Router.new do
        get "/ping" do |env|
          env.response.print("pong")
        end

        get "/developers/:id", Actions::Developers::Get
        get "/developers", Actions::Developers::Index
        patch "/developers/:id", Actions::Developers::Update

        get "/oauth/github/init", Actions::OAuth::GitHub::Init
        get "/oauth/github/callback", Actions::OAuth::GitHub::Callback
      end
    end
  end
end
