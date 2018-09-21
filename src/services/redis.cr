require "redis"

runtime_env REDIS_URL

class Services::Redis
  class_getter instance = ::Redis::PooledClient.new(url: ENV["REDIS_URL"])
end

def redis
  Services::Redis.instance
end

redis.ping
