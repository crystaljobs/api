require "../../decorators/developer"
require "../../../ext/object"

module Server::Actions
  struct Developers::Update
    include Prism::Action
    include Prism::Action::Params
    include Prism::Action::Auth(Server::Auth::Authenticator)

    authenticate

    params do
      type about : String? | Null, validate: {size: (1..300)}
      type website : String? | Null, validate: {regex: %r{^https?://}}
      type country : String? | Null, validate: {size: 2}
      type display : Bool?
    end

    def call
      dev = repo.query(Developer.where(id: auth.dev.id)).first

      case params["about"]
      when Null      then dev.about = nil
      when .not_nil? then dev.about = params["about"].as(String)
      end

      case params["website"]
      when Null      then dev.website = nil
      when .not_nil? then dev.website = URI.parse(params["website"].as(String))
      end

      case params["country"]
      when Null      then dev.country = nil
      when .not_nil? then dev.country = params["country"].as(String)
      end

      if params["display"].is_a?(Bool)
        dev.display = params["display"].as(Bool)
      end

      halt!(400, "No changes to apply") unless dev.changes.any?

      begin
        dev = repo.query(dev.valid!.update).first
      rescue e : Validations::Error
        halt!(400, e.message)
      end

      json(202, {
        developer: Decorators::Developer.new(dev, display: true),
      })
    end
  end
end
