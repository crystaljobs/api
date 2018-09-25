require "../../../../lib/github/client"
require "../../../../services/redis"

runtime_env GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET

module Server::Actions
  struct OAuth::GitHub::Callback
    include Prism::Action
    include Prism::Action::Params

    params do
      type code : String
      type state : String
    end

    def call
      halt!(404, "Unknown state") unless redis.get("oauth:github:state:#{params[:state]}")

      client = ::GitHub::Client.new(ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"])
      github_token = client.get_access_token(params[:code], params[:state])

      api_client = ::GitHub::API::Client.new
      api_client.access_token = github_token.access_token
      github_user = api_client.get_authenticated_user

      dev = repo.query(Developer.where(github_id: github_user.id)).first?

      if dev
        dev.github_access_token = github_token.access_token
        dev.github_username = github_user.login

        if dev.changes.any?
          repo.exec(dev.valid!.update)
        end
      else
        website = if github_user.blog.size > 0
                    begin
                      uri = URI.parse(github_user.blog)
                      uri if uri.http?
                    rescue
                    end
                  end

        dev = Developer.new(
          website: website,
          about: github_user.bio,
          github_id: github_user.id,
          github_username: github_user.login,
          github_access_token: github_token.access_token,
        )

        dev = repo.query(dev.valid!.insert.returning(:id)).first
      end

      json({
        developer: {
          id: dev.id,
        },
        jwt: Server::Auth::Tokenizer.new(dev).tokenize,
      })
    end
  end
end
