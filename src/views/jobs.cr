struct Views::Jobs
  include Atom::View

  def initialize(@jobs : Array(::Job), *, @named_object = true, @sensitive_information = false)
  end

  def render(json)
    json.array do
      @jobs.each do |user|
        Views::Job.new(user, named_object: false, sensitive_information: @sensitive_information).to_json(json)
      end
    end
  end

  def to_json(json)
    if @named_object
      json.object do
        json.field "jobs" do
          render(json)
        end
      end
    else
      render(json)
    end
  end
end
