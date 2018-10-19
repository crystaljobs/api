module Postmark
  class Client
    BASE_URL = URI.parse("https://api.postmarkapp.com")

    def initialize(server_token : String)
      @client = HTTP::Client.new(BASE_URL)
      @client.before_request do |request|
        request.headers["X-Postmark-Server-Token"] = server_token
        request.headers["Accept"] = "application/json"
        request.headers["Content-Type"] = "application/json"
      end
    end

    def deliver_with_template(*, template_id : Int32? = nil, template_alias : String? = nil, template_model : Hash, from : String, to : String, tag : String? = nil)
      body = String::Builder.build do |string|
        json = JSON::Builder.new(string)
        json.document do
          json.object do
            if template_id
              json.field "TemplateId", template_id
            elsif template_alias
              json.field "TemplateAlias", template_alias
            else
              raise ArgumentError.new("Either template_id or template_alias is required")
            end

            json.field "TemplateModel" do
              template_model.to_json(json)
            end

            json.field "From", from
            json.field "To", to

            if tag
              json.field "Tag", tag
            end
          end
        end
      end

      pp! body

      response = @client.post("/email/withTemplate", body: body)
    end
  end
end
