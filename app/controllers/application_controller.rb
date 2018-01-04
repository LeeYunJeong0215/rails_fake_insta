class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "권한없지롱~"
    redirect_to '/'
    # respond_to do |format|
    #   format.json { render nothing: true, :status => :forbidden }
    #   format.xml { render xml: "...", :status => :forbidden }
    #   format.html { redirect_to main_app.root_url, :alert => exception.message }
    end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
