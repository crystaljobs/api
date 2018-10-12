runtime_env ADMIN_DEVELOPER_IDS

struct Actions::Developers::Update
  include Atom::Action

  patch "/developers/:id"

  ADMIN_DEVELOPER_IDS = ENV["ADMIN_DEVELOPER_IDS"].split(",").map(&.to_i32)

  auth Developer do
    auth.developer.id == params.id || ADMIN_DEVELOPER_IDS.includes?(auth.developer.id)
  end

  params do
    type id : Int32
    type about : Union(String, Nil, Null)
    type website : Union(String, Nil, Null)
    type country : Union(String, Nil, Null)
    type display : Bool | Nil
    type status : String | Nil
  end

  errors do
    type DeveloperNotFound(404)
    type AdminAccessRequired(403)
    type NoChangesToApply(409)
    type InvalidDeveloper(400), invalid_attributes : Hash(String, Array(String))
  end

  def call
    dev = Atom.query(Developer.where(id: params.id)).first?
    raise DeveloperNotFound.new unless dev

    if status = params.status
      raise AdminAccessRequired.new unless ADMIN_DEVELOPER_IDS.includes?(auth.developer.id)
      dev.status = Developer::Status.parse(status)
    end

    case params.about
    when Null      then dev.about = nil
    when .not_nil? then dev.about = params.about.as(String)
    end

    case params.website
    when Null      then dev.website = nil
    when .not_nil? then dev.website = URI.parse(params.website.as(String))
    end

    case params.country
    when Null      then dev.country = nil
    when .not_nil? then dev.country = params.country.as(String)
    end

    if params.display.is_a?(Bool)
      dev.display = params.display.as(Bool)
    end

    raise NoChangesToApply.new unless dev.changes.any?
    raise InvalidDeveloper.new(dev.invalid_attributes) unless dev.valid?

    Atom.exec(dev.update)
  end
end
