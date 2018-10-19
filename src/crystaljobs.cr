require "pg"

require "atom"
require "atom/model"

require "./models/**"
require "./views/**"
require "./actions/**"

runtime_env DOMAIN

Atom.json

Atom.jwt Job,
  iat: Time.now.epoch,
  iss: ENV["DOMAIN"],
  sub: "jobAuth",
  ver: 1,
  min_ver: 1

Atom.jwt User,
  iat: Time.now.epoch,
  iss: ENV["DOMAIN"],
  exp: (Time.now + 1.month).epoch,
  sub: "userAuth",
  ver: 1,
  min_ver: 1

Atom.run
