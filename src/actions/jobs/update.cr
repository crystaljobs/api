require "../../lib/postmark"

runtime_env APP_URL, APP_FROM, POSTMARK_SERVER_TOKEN, POSTMARK_TID_JOB_APPROVAL

struct Actions::Jobs::Update
  include Atom::Action

  patch "/jobs/:id"

  params do
    type id : Int32
    type status : String | Nil # TODO: https://github.com/vladfaust/params.cr/issues/8
    type published : Bool | Nil

    type budget : Int32 | Nil # Budget cannot be deleted

    type title : String | Nil                  # Title cannot be deleted
    type location : Union(String | Nil | Null) # Location can be updated or deleted
    type description : String | Nil            # Description cannot be deleted
    type salary : Int32 | Nil                  # Salary cannot be deleted

    type apply_url : Union(String | Nil | Null)
    type apply_email : Union(String | Nil | Null)

    type employer_image : Union(String | Nil | Null) # Image can be updated or deleted
  end

  errors do
    type JobNotFound(404)
    type Unauthorized(403)
    type CannotChangeStatus(403)
    type NoChangesToApply(409)
    type InvalidJob(400), errors : Hash(String, Array(String))
  end

  auth job do
    raise Unauthorized.new unless auth.job.id == params.id
  end

  auth user do
    raise Unauthorized.new unless auth.user.moderator
  end

  def call
    job = Atom.query(Job.where(id: params.id)).first?
    raise JobNotFound.new unless job

    would_send_approval_email = false

    unless params.status.nil?
      raise CannotChangeStatus.new unless auth.user?

      new_status = Job::ApprovalStatus.parse(params.status.as(String))
      if new_status.approved? && job.status.pending? && !job.approval_email_sent
        would_send_approval_email = true
      end

      job.status = new_status
    end

    unless params.published.nil?
      job.published = params.published.as(Bool)
    end

    unless params.budget.nil?
      job.budget = params.budget.as(Int32)
    end

    unless params.title.nil?
      job.title = params.title.as(String)
    end

    case params.location
    when Null then job.location = nil
    when nil
    else job.location = params.location.as(String)
    end

    unless params.description.nil?
      job.description = params.description.as(String)
    end

    unless params.salary.nil?
      job.salary = params.salary.as(Int32)
    end

    case params.apply_url
    when Null then job.apply_url = nil
    when nil
    else job.apply_url = URI.parse(params.apply_url.as(String))
    end

    case params.apply_email
    when Null then job.apply_email = nil
    when nil
    else job.apply_email = params.apply_email.as(String)
    end

    case params.employer_image
    when Null then job.employer_image = nil
    when nil
    else job.employer_image = URI.parse(params.employer_image.as(String))
    end

    raise NoChangesToApply.new unless job.changes.any?
    raise InvalidJob.new(job.invalid_attributes) unless job.valid?

    spawn do
      Atom.exec(job.not_nil!.update)

      if would_send_approval_email
        jwt = Atom.jwtize(job.not_nil!)

        postmark = Postmark::Client.new(ENV["POSTMARK_SERVER_TOKEN"])
        pp postmark.deliver_with_template(
          template_id: ENV["POSTMARK_TID_JOB_APPROVAL"].to_i,
          template_model: {
            "jobTitle" => job.not_nil!.title,
            "appURL"   => ENV["APP_URL"],
            "editURL"  => ENV["APP_URL"] + "/jobs/edit?token=#{jwt}",
          },
          from: ENV["APP_FROM"],
          to: job.not_nil!.employer_email,
          tag: "jobApproval"
        )

        job.not_nil!.approval_email_sent = true
        Atom.exec(job.not_nil!.update)
      end
    end

    status(201)
  end
end
