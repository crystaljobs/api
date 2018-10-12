class Developer
  include Atom::Model

  enum Status
    Pending
    Approved
    Declined
  end

  schema developers do
    pkey id : Int32

    type about : Union(String, Nil)
    type website : Union(URI, Nil)
    type country : Union(String, Nil)
    type display : Bool = DB::Default
    type status : Status = DB::Default

    type github_id : Int32
    type github_username : String
    type github_access_token : String

    type created_at : Time = DB::Default
  end

  validate about, size: (1..300)
  validate country, size: 2

  def validate
    previous_def

    invalidate("website", "must be an HTTP(S) URI") if website && !website.not_nil!.http?
  end

  def to_jwt(jwt)
    {id: id}.to_json(jwt)
  end

  def self.from_jwt(jwt)
    id = jwt["id"].as_i
    github_id = uninitialized Int32
    github_username = uninitialized String
    github_access_token = uninitialized String
    new(id: id, github_id: github_id, github_username: github_username, github_access_token: github_access_token)
  end
end
