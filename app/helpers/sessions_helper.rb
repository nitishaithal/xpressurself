module SessionsHelper

	def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
    session[:return_to] = root_url
  end

   def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by remember_token: cookies[:remember_token]
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    current_user = nil
    session.delete(:return_to)
    cookies.delete(:remember_token)
    session[:return_to] = root_url
  end

    def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end 

    def signed_in_user
      unless signed_in?
        store_location
        #redirect_to signin_url, notice: "Please sign in."
        redirect_to root_url, notice: "Please sign in."
      end
    end


  def remote_ip
    if request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '117.192.176.246'
    else
      request.remote_ip
    end
  end


  def facebook
    @graph = Koala::Facebook::API.new(session['fb_access_token'])
  end

  def fb_friends
      @friends = Array.new
    if session["fb_access_token"].present?
      # @profile_image = graph.get_picture("me")
      # @fbprofile = graph.get_object("me")
      @friends = facebook.get_connections("me", "friends")
    end
    @friends
  end

  def profile_pics
    @arr = facebook.get_connections("me","albums").map {|p| p["id"] if p["name"] == "Profile Pictures" }.compact
    @photo_ids = []
    unless @arr.empty?
      album_id = @arr[0]
      @user_pics = current_user.fb_pictures
      if @user_pics.nil?
        @photo_ids = facebook.get_connections(album_id, "photos").map {|p| p["id"]}
      else
        pics = []
        pics = facebook.get_connections(album_id, "photos").map {|p| p["id"]}
        pics.each do |pic|
          unless @user_pics.include?(pic)
             current_user.fb_pictures << pic
             @photo_ids << pic
          end
        end
      end
    end
    @photo_ids
  end

end
