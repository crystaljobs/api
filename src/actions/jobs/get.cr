struct Actions::Jobs::Get
  include Atom::Action

  get "/jobs/:id"

  params do
    type id : Int32
  end

  errors do
    type JobNotFound(404)
  end

  def call
    if auth_job = auth?.try &.job?
      query = Job.where(id: params.id)
      sensitive_information = true
    else
      query = Job.where(
        id: params.id,
        status: Job::ApprovalStatus::Approved,
        published: true,
        activated: true
      ).and("expired_at > now()")
    end

    job = Atom.query(query).first?
    raise JobNotFound.new unless job

    return Views::Job.new(job, sensitive_information: !!sensitive_information)
  end
end
