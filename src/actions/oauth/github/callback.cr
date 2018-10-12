runtime_env GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET

struct Actions::OAuth::GitHub::Callback
  include Atom::Action

  get "/oauth/github/callback"

  params do
    type code : String
    type state : String
  end

  errors do
    type UnknownState(404)
  end

  def call
    raise UnknownState.new unless Atom.redis.get("oauth:github:state:#{params.state}")

    client = ::GitHub::Client.new(ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"])
    github_token = client.get_access_token(params.code, params.state)

    api_client = ::GitHub::API::Client.new
    api_client.access_token = github_token.access_token
    github_user = api_client.get_authenticated_user

    dev = Atom.query(Developer.where(github_id: github_user.id)).first?

    if dev
      dev.github_access_token = github_token.access_token
      dev.github_username = github_user.login

      if dev.changes.any?
        Atom.exec(dev.valid!.update)
      end
    else
      if github_user.blog.size > 0
        begin
          uri = URI.parse(github_user.blog)
          website = uri if uri.http?
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

      dev = Atom.query(dev.valid!.insert.returning(:id)).first
    end

    return Views::JWT.new(Atom.jwtize(dev))
  end
end
