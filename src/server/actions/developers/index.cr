require "../../decorators/developer"

runtime_env ADMIN_DEVELOPER_IDS

module Server::Actions
  struct Developers::Index
    include Prism::Action
    include Prism::Action::Auth(Server::Auth::Authenticator)

    ADMIN_DEVELOPER_IDS = ENV["ADMIN_DEVELOPER_IDS"].split(",").map(&.to_i32)

    def call
      render_display_attribute = false
      query = Developer.order_by(:created_at, :desc)

      if auth?.try &.authenticate && ADMIN_DEVELOPER_IDS.includes?(auth.dev.id)
        render_display_attribute = true
      else
        query = query.where(display: true).and(status: Developer::Status::Approved)
      end

      devs = repo.query(query)

      json({
        developers: devs.map do |dev|
          Decorators::Developer.new(dev, display: render_display_attribute)
        end,
      })
    end
  end
end
