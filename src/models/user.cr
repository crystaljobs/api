class User
  include Atom::Model

  schema users do
    pkey id : Int32

    type email : String
    type password : String, key: "encrypted_password"
    type moderator : Bool = DB::Default

    type created_at : Time = DB::Default
    type updated_at : Union(Time, Nil)
  end

  validate email, regex: /@/, size: (5..50)

  def to_jwt(jwt)
    {id: id, moderator: moderator}.to_json(jwt)
  end

  def self.from_jwt(jwt)
    email = uninitialized String
    password = uninitialized String

    new(
      id: jwt["id"].as_i,
      email: email,
      password: password,
      moderator: jwt["moderator"].as_bool,
    )
  end
end
