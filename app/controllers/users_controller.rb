class UsersController < ApplicationController
  before_filter :login_required, :only => ['change_password', 'destroy', 'index', 'logout', 'change_password', 'show', 'edit']

  def index
    @users = User.all
    @user = session[:user]
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def new
    @user = User.new(params[:user])
  end

  def create
    @user = User.new(params[:user])

    if request.post?
      if @user.save

        if @user.id == 1
          @user.admin = true
        else
          @user.admin = false
        end

        if @user.email == nil
          @user.email = "broken@strange.com"
        end
        
        @user.save
        
        session[:user] = User.authenticate(@user.login, @user.password)
        @user.send_welcome # welcome email
        flash[:message] = "Registration Successful"
        redirect_to root_url         
      else
        flash[:warning] = "Registration Unsuccessful"
        redirect_to root_url + 'users/register'
      end
    end
  end

  def login
    if request.post?
      if session[:user] = User.authenticate(params[:user][:login], params[:user][:password])
      flash[:notice] = "Logged In"
      redirect_to root_url
      else
        flash[:warning] = "Login Failed"
        redirect_to root_url, :notice => "Login Failed"
      end
    end
  end

  def logout
    session[:user] = nil
    flash[:message] = "Logged Out"
    redirect_to root_url
  end

  def forgot_password
    if request.post?
      usr = User.find_by_email(params[:user][:email])
      usr.send_new_password if usr
      if ActionMailer::Base.deliveries.empty? 
        flash[:notice] = "Email not registered."
      end
      #flash[:notice] = "A new password has been sent to your email."
      redirect_to root_url, :notice => "A new password has been sent to your email."
      else
        flash[:warning] = "Couldn't send new password"
    end
  end

  def change_password
    @user = session[:user]
    if request.post?
      @user.update_attributes(:password=>params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        redirect_to root_url, :notice => "Password Successfully Changed."
      end
      redirect_to root_url, :notice => "Password NOT Changed."
    end
    
  end
  
  def set_admin(curr_user)
    curr_user.admin = true
  end
  helper_method :set_admin
  
  def rm_admin(curr_user)
    curr_user.admin = false
  end
  helper_method :rm_admin
  
  def show
    @curr = User.find(params[:id])
    @user = session[:user]
    if @curr != @user and !@curr.admin
      redirect_to user_path(@user)
    end
  end
  
  def edit
    @curr = User.find(params[:id])
    @user = session[:user]
    if @curr != @user and !@curr.admin
      redirect_to user_path(@user)
    end
  end
  
  def update

    @curr = User.find(params[:id])
 
    if @curr.update_attributes(params[:user])
      @curr.save
      flash[:notice] = "Successfully updated user."
    else
      flash[:notice] = "Unable to update user."
    end  
    redirect_to user_path(@curr)
  end
=begin
    if request.put?  
      if @curr.save
        session[:user] = User.authenticate(@curr.login, @curr.password)
        flash[:message] = "Update Successful"
        #redirect_to root_url         
      else
        flash[:warning] = "Update Unsuccessful"
      end
    end
    
    respond_to do |format|
      if @curr.update_attributes(params[:user])
        session[:user] = User.authenticate(@user.login, @user.password)
        flash[:message] = "Update Successful"
      else
        #format.html { render action: "edit" }
        flash[:message] = "Update Unsuccessful"
      end
    end
=end

  # def update  
  #  @product = Product.find(params[:id])  
  #  if @product.update_attributes(params[:product])  
  #    flash[:notice] = "Successfully updated product."  
  #  end  
  #  respond_with(@product)  
  #end

  def check_email
    @user = User.find_by_email(params[:user][:email])
    
    respond_to do |format|
      format.json { render :json => !@user }
    end
  end
  
  def check_login
    @user = User.find_by_login(params[:user][:login])
    
    respond_to do |format|
      format.json { render :json => !@user }
    end
  end
  
  def destroy
    
  end
end
