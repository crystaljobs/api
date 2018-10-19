struct Actions::Jobs::Activate
  include Atom::Action

  patch "/jobs/:id/activate"

  params do
    type id : Int32
  end

  errors do
    type JobNotFound(404)
    type Unauthorized(403)
    type AlreadyActive(409)
  end

  auth job do
    raise Unauthorized.new unless auth.job.id == params.id
  end

  def call
    job = Atom.query(Job.where(id: params.id).select(:id, :activated)).first?
    raise JobNotFound.new unless job
    raise AlreadyActive.new if job.activated

    job.activated = true

    spawn do
      Atom.exec(job.not_nil!.update)
    end

    status(201)
  end
end
