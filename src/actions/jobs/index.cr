struct Actions::Jobs::Index
  include Atom::Action

  get "/jobs"

  def call
    jobs = Atom.query(Job.where(
      status: Job::ApprovalStatus::Approved,
      published: true,
      activated: true,
    ).and("expired_at > now()").order_by(:id, :desc))
    return Views::Jobs.new(jobs)
  end
end
