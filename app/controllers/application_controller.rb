class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  helper_method :current_account

  private

  def current_account
    Current.account
  end

  def pundit_user
    Current.user
  end

  def forbidden
    redirect_back fallback_location: root_path, alert: "You are not allowed to do that."
  end
end
