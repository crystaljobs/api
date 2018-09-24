class ErrorHandler
  include HTTP::Handler

  def initialize(@logger : Logger, @verbose : Bool = false)
  end

  def call(context)
    begin
      call_next(context)
    rescue ex : Exception
      @logger.error(ex.inspect_with_backtrace)

      if @verbose
        context.response.reset
        context.response.status_code = 500
        context.response.content_type = "text/plain"
        context.response.print("ERROR: ")
        ex.inspect_with_backtrace(context.response)
      else
        context.response.respond_with_error
      end
    end
  end
end
