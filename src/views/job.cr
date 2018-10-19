struct Views::Job
  include Atom::View

  def initialize(@job : ::Job, *, @named_object = true, @sensitive_information = false)
  end

  def render(json)
    json.object do
      json.field "id", @job.id

      if @sensitive_information
        json.field "status", @job.status.to_s # TODO: .lower_camelcase
        json.field "published", @job.published
      end

      json.field "oneOff", @job.one_off
      json.field "budget", @job.budget

      json.field "title", @job.title
      json.field "location", @job.location
      json.field "description", @job.description
      json.field "salary", @job.salary

      json.field "applyURL", @job.apply_url.try &.to_s
      json.field "applyEmail", @job.apply_email

      json.field "employerName", @job.employer_name
      json.field "employerImage", @job.employer_image.try &.to_s

      json.field "createdAt", @job.created_at.epoch
      json.field "updatedAt", @job.updated_at.try &.epoch
      json.field "expired_at", @job.expired_at.epoch
    end
  end

  def to_json(json)
    if @named_object
      json.object do
        json.field("job") do
          render(json)
        end
      end
    else
      render(json)
    end
  end
end
