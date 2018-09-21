require "dotenv"

ENV["APP_ENV"] = "development" unless ENV.has_key?("APP_ENV")
Dotenv.load(".env.#{ENV["APP_ENV"]}") if ENV["APP_ENV"] != "production"

macro runtime_env(*envs)
  {% for env in envs %}
    raise "Runtime environment variable {{env}} is not defined!" unless ENV.has_key?("{{env}}")
  {% end %}
end

macro buildtime_env(*env)
  {% for var in envs %}
    {% raise "Buildtime environment variable #{var} is not defined!" unless env("#{var}") %}
  {% end %}
end
