require "../../ext/string"

module Server::Decorators
  struct Developer
    def initialize(@developer : ::Developer, *, @display = false)
    end

    def to_json(builder)
      builder.object do
        builder.field("id", @developer.id)
        builder.field("about", @developer.about)
        builder.field("website", @developer.website.try &.to_s)
        builder.field("country", @developer.country)
        builder.field("display", @developer.display) if @display
        builder.field("status", @developer.status.to_s.lower_camelcase)
        builder.field("github") do
          builder.object do
            builder.field("id", @developer.github_id)
            builder.field("username", @developer.github_username)
          end
        end
      end
    end
  end
end
