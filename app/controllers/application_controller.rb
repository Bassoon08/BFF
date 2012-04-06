class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prepair_for_mobile
  before_filter :set_user_time_zone
  
  def login_required
    if session[:user]
      return true
    end
    flash[:warning]='Please login to continue'
    session[:return_to]=request.request_uri
    redirect_to :controller => "user", :action => "login"
    return false 
  end

  def current_user_session
    User.find(session[:User])
  end
  
  def current_user
    return User.find(session[:user])
  end
  helper_method :current_user

  def isAdmin?
    return current_user.admin
  end
  helper_method :isAdmin?

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to_url(return_to)
    else
      redirect_to :controller=>'user', :action=>'welcome'
    end
  end
  
  private
 
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def set_user_time_zone
    Time.zone = current_user.time_zone if session[:user] != nil
  end
  helper_method :set_user_time_zone

  def prepair_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end
end
