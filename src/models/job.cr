class Job
  include Atom::Model

  enum ApprovalStatus
    Pending
    Approved
    Rejected
  end

  schema jobs do
    pkey id : Int32

    type status : ApprovalStatus = DB::Default
    type activated : Bool = DB::Default
    type published : Bool = DB::Default

    type approval_email_sent : Bool = DB::Default

    type one_off : Bool
    type budget : Union(Int32, Nil)

    type title : String
    type location : Union(String, Nil)
    type description : String
    type salary : Union(Int32, Nil)

    type apply_url : Union(URI, Nil)
    type apply_email : Union(String, Nil)

    type employer_name : String
    type employer_email : String
    type employer_image : Union(URI, Nil)

    type created_at : Time = DB::Default
    type updated_at : Union(Time, Nil)
    type expired_at : Time
  end

  validate budget, gt: 0, lte: 1_000_000

  validate title, size: (3..50)
  validate location, size: (2..50)
  validate description, size: (100..2000)
  validate salary, gt: 0, lte: 1_000_000

  validate apply_email, regex: /@/, size: (5..50)

  validate employer_name, size: (3..50)
  validate employer_email, regex: /@/, size: (5..50)

  def validate
    previous_def

    # TODO: https://github.com/vladfaust/validations.cr/issues/7
    invalidate("job", "must have either apply_url or apply_email") unless apply_url || apply_email
  end

  def to_jwt(jwt)
    {id: id}.to_json(jwt)
  end

  def self.from_jwt(jwt)
    one_off = uninitialized Bool
    title = uninitialized String
    description = uninitialized String
    employer_name = uninitialized String
    employer_email = uninitialized String
    expired_at = uninitialized Time

    new(
      id: jwt["id"].as_i,
      one_off: one_off,
      title: title,
      description: description,
      employer_name: employer_name,
      employer_email: employer_email,
      expired_at: expired_at,
    )
  end
end
