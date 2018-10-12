struct Views::Developer
  include Atom::View

  def initialize(@developer : ::Developer, *, @display = false, @nested = true)
  end

  def main(json)
    json.object do
      json.field("id", @developer.id)
      json.field("about", @developer.about)
      json.field("website", @developer.website.try &.to_s)
      json.field("country", @developer.country)
      json.field("display", @developer.display) if @display
      json.field("status", @developer.status.to_s.lower_camelcase)
      json.field("github") do
        json.object do
          json.field("id", @developer.github_id)
          json.field("username", @developer.github_username)
        end
      end
    end
  end

  def to_json(json)
    if @nested
      json.object do
        json.field("developer") do
          main(json)
        end
      end
    else
      main(json)
    end
  end
end
