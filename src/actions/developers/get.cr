struct Actions::Developers::Get
  include Atom::Action

  get "/developers/:id"

  params do
    type id : Int32
  end

  errors do
    type DeveloperNotFound(404)
  end

  def call
    render_display_attribute = false
    query = Developer.where(id: params.id)

    if auth?.try &.developer?.try &.id == params.id
      render_display_attribute = true
    else
      query = query.where(display: true, status: Developer::Status::Approved)
    end

    dev = Atom.query(query).first?
    raise DeveloperNotFound.new unless dev

    return Views::Developer.new(dev, display: render_display_attribute)
  end
end
