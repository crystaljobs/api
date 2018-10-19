require "../../lib/postmark"

runtime_env APP_URL, APP_FROM, POSTMARK_SERVER_TOKEN, POSTMARK_TID_JOB_ACTIVATION

struct Actions::Jobs::Create
  include Atom::Action

  post "/jobs"

  params do
    type one_off : Bool
    type budget : Int32 | Nil

    type title : String
    type location : String | Nil
    type description : String
    type salary : Int32 | Nil

    type apply_url : String | Nil
    type apply_email : String | Nil

    type employer_name : String
    type employer_email : String
    type employer_image : String | Nil
  end

  errors do
    type InvalidJob(400), errors : Hash(String, Array(String))
  end

  def call
    job = Job.new(
      one_off: params.one_off,
      budget: params.budget,

      title: params.title,
      location: params.location,
      description: params.description,
      salary: params.salary,

      # TODO: https://github.com/vladfaust/params.cr/issues/8
      apply_url: (URI.parse(params.apply_url.as(String)) if params.apply_url),
      apply_email: params.apply_email,

      employer_name: params.employer_name,
      employer_email: params.employer_email,

      # TODO: https://github.com/vladfaust/params.cr/issues/8
      employer_image: (URI.parse(params.employer_image.as(String)) if params.employer_image),

      expired_at: Time.now + 30.days,
    )

    raise InvalidJob.new(job.invalid_attributes) unless job.valid?

    spawn do
      job = Atom.query(job.insert).first
      jwt = Atom.jwtize(job)

      postmark = Postmark::Client.new(ENV["POSTMARK_SERVER_TOKEN"])
      pp postmark.deliver_with_template(
        template_id: ENV["POSTMARK_TID_JOB_ACTIVATION"].to_i,
        template_model: {
          "jobTitle"    => params.title,
          "appURL"      => ENV["APP_URL"],
          "activateURL" => ENV["APP_URL"] + "/jobs/activate?token=#{jwt}",
        },
        from: ENV["APP_FROM"],
        to: params.employer_email,
        tag: "jobActivation"
      )

      puts "JWT: #{jwt}"
    end

    status(201)
  end
end
