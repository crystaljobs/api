require "crypto/bcrypt"

struct Actions::Users::Login
  include Atom::Action

  post "/users/login"

  params do
    type email : String
    type password : String
  end

  errors do
    type UserNotFound(404)
    type Unauthenticated(401)
  end

  def call
    user = Atom.query(User.where(email: params.email)).first?

    raise UserNotFound.new unless user
    raise Unauthenticated.new unless Crypto::Bcrypt::Password.new(user.password) == params.password

    return Views::UserJWT.new(Atom.jwtize(user))
  end
end
