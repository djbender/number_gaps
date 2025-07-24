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
end
