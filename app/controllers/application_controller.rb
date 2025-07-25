class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action do
    Rails.error.set_context(
      request_url: request.original_url,
      params: params,
      session: session.inspect
    )
  end

  if Rails.env.development?
    rescue_from StandardError do |exception|
      # Rails.error.report(exception) # This happens automatically anyway
      redirect_to solid_errors.error_path(SolidErrors::Error.last), status: 307
    end
  end
end
