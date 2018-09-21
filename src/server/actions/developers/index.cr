require "../../decorators/developer"

module Server::Actions
  struct Developers::Index
    include Prism::Action

    def call
      devs = repo.query(Developer.where(display: true))

      json({
        developers: devs.map do |dev|
          Decorators::Developer.new(dev)
        end,
      })
    end
  end
end
