struct Views::Developers
  include Atom::View

  def initialize(@developers : Array(::Developer), *, @display = false, @nested = true)
  end

  def main(json)
    json.array do
      @developers.each do |dev|
        Views::Developer.new(dev, display: @display, nested: false).to_json(json)
      end
    end
  end

  def to_json(json)
    if @nested
      json.object do
        json.field "developers" do
          main(json)
        end
      end
    else
      main(json)
    end
  end
end
