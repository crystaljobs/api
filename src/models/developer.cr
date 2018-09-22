require "validations"
require "../ext/uri"

class Developer
  include Core::Schema
  include Validations

  enum Status
    Pending
    Approved
    Declined
  end

  schema developers do
    pkey id : Int32

    type about : Union(String | Nil)
    type website : Union(URI | Nil)
    type country : Union(String | Nil)
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
end
