require "../../decorators/developer"
require "../../auth/authenticator"

module Server::Actions
  struct Developers::Get
    include Prism::Action
    include Prism::Action::Params
    include Prism::Action::Auth(Server::Auth::Authenticator)

    params do
      type id : UInt32
    end

    def call
      render_display_attribute = false

      if auth?.try &.authenticate
        if auth.dev.id == params["id"]
          dev = repo.query(Developer.where(id: params["id"].to_i32)).first?
          render_display_attribute = true
        else
          dev = repo.query(Developer.where(id: params["id"].to_i32, display: true)).first?
        end
      else
        dev = repo.query(Developer.where(id: params["id"].to_i32, display: true)).first?
      end

      halt!(404) unless dev

      json({
        developer: Decorators::Developer.new(dev, display: render_display_attribute),
      })
    end
  end
end
