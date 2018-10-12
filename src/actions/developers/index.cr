runtime_env ADMIN_DEVELOPER_IDS

struct Actions::Developers::Index
  include Atom::Action

  get "/developers"

  ADMIN_DEVELOPER_IDS = ENV["ADMIN_DEVELOPER_IDS"].split(",").map(&.to_i32)

  def call
    render_display_attribute = false
    query = Developer.order_by(:created_at, :desc)

    if auth?.try &.authenticated? && ADMIN_DEVELOPER_IDS.includes?(auth.developer.id)
      render_display_attribute = true
    else
      query = query.where(display: true).and(status: Developer::Status::Approved)
    end

    return Views::Developers.new(Atom.query(query), display: render_display_attribute)
  end
end
