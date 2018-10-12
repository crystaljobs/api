require "pg"

require "atom"
require "atom/model"
require "atom/redis"

require "./ext/**"

# TODO: Move to an external shard
require "./lib/github"

require "./models/**"
require "./views/**"
require "./actions/**"

runtime_env DOMAIN

# Enable JWT-based authentication for Developer
# with default values
Atom.jwt Developer,
  exp: (Time.now + 1.month).epoch,
  iss: ENV["DOMAIN"],
  iat: Time.now.epoch,
  sub: "devAuth"

# Enable simple JSON API formatting
Atom.json

Atom.run
