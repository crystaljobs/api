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
      query = Developer.where(id: params["id"].to_i32)

      if auth?.try &.authenticate && auth.dev.id == params["id"]
        render_display_attribute = true
      else
        query = query.where(display: true, status: Developer::Status::Approved)
      end

      dev = repo.query(query).first?
      halt!(404) unless dev

      json({
        developer: Decorators::Developer.new(dev, display: render_display_attribute),
      })
    end
  end
end
