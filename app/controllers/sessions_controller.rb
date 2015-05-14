class SessionsController < ApplicationController
  def new
  end

  def create
 
  end

  def destroy
    sign_out
    redirect_to root_url, :notice => "Logged out!"
  end

  def failure  
    redirect_to root_path, alert: "Authentication failed, please try again."  
  end

end
