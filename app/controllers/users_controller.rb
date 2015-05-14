class UsersController < ApplicationController
autocomplete :location, :address, :full => true

  def login
    oauth = request.env["omniauth.auth"]
    @user = User.find_by(uid: oauth['uid'])
    #session['fb_auth'] = oauth

    if  @user.nil?
      @user = User.create_with_omniauth(oauth)
   #   @user = User.find_by(email: oauth['extra']['raw_info']['email'])
    end
    unless  @user.username.present? 
      @user = update_with_omniauth(@user, oauth)
    end
    @user.fb_access_token = oauth['credentials']['token']
    session['fb_access_token'] = oauth['credentials']['token']
    session['fb_error'] = nil
    @user.save!
    sign_in @user
    
    @graph = Koala::Facebook::API.new(@user.fb_access_token)
    @user.pictures =  []
    @user.visible_pictures = []
    if @user.default_pic.nil?
      @user.default_pic =  Cloudinary::Uploader.upload(@graph.get_picture(@user.uid,:type => "square", height: 400 , width: 400))["public_id"]
      default_pic = @user.default_pic
      @user.pictures << default_pic
      @user.visible_pictures << default_pic
    end
    @user.save!
    @pics = @user.pictures
    @v_pics = @user.visible_pictures

       @user.pictures = nil
       @user.visible_pictures = nil
       @user.save!

    unless profile_pics.empty?
      profile_pics.each do |pic_id|
        picture =  Cloudinary::Uploader.upload(@graph.get_object(pic_id)["source"])["public_id"]
        @pics << picture
        @v_pics << picture
      end
    end
    @user.pictures =  @pics
    @user.visible_pictures =  @v_pics

    @friends = @graph.get_connections("me", "friends")
    @user.friends_list = @friends
    @user.save!
    
    create_fb_friends(@user.uid, @friends)
    sign_in @user
    redirect_to root_path
  end

  def friends
    @friends = []
    unless current_user.gender == 'male'
        #@friends = current_user.friend_boys.paginate(:page => params[:page], :per_page => 8)
        @friends = current_user.friend_boys.limit(8)
    else
        @friends = current_user.friend_girls.limit(8)
    end
  end

  def page_friends
        @friends = []
    unless current_user.gender == 'male'
        @friends = current_user.friend_boys.skip((8) * params[:page].to_i-8).limit(8)
    else
        @friends = current_user.friend_girls.skip((8) * params[:page].to_i-8).limit(8)
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    unless @user.uuid == current_user.uuid
      unless  current_user.rels(dir: :outgoing, type: :visits, between: @user).blank?
        rel = current_user.rels(dir: :outgoing, type: :visits, between: @user)
        rel[0].count = rel[0].count + 1
        rel[0].save!
      else
        rel = Visit.new
        rel.from_node = current_user
        rel.to_node = @user
        rel.count = 1
        rel.save!
      end
        current_user.save!
    end
    #@b = current_user.badges(:u, :r).where( uuid: @user.uuid ).pluck(:r)
    #@badges = @b.map {|b| b.badgeType}.uniq
    @uniq_badges =  @user.rels(dir: :incoming, type: :badges).each.map {|r| r.badgeType}.uniq
    @all_badges = {}
    @uniq_badges.each do |badge|
      @all_badges[badge] = @user.rels(dir: :incoming, type: :badges).each.select{|r| r.badgeType == badge }.count
    end
    @my_badges = []
    @badges_count = @user.rels(dir: :incoming, type: "badges").count
    if current_user.uuid != @user.uuid
        current_user.rels(dir: :outgoing, type: :badges, between: @user).each do |r|
        #current_user.badges(:u, :r).where( uuid: @user.uuid ).each_with_rel do |u, r| 
        @my_badges << r[:badgeType]
      end
    end
    @pictures = @user.pictures
    @testimonials = @user.testimonials

    unless @user.uuid == current_user.uuid
      @like = current_user.rels(dir: :outgoing, type: :likes, between: @user).blank? ? true : false
    end
    @likes_count = @user.rels(dir: :incoming, type: "likes").count

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def autocomplete_location_address
    gc = Geocoder.search(params[:address])
    result = gc.collect do |t|
      {value: t.address}
    end
    respond_to do |format|
      format.json {render json: result}
    end
  end

  def add_location
    gc = Geocoder.search(params[:address])[0]
      @location = Location.find_by(address: gc.address)
      if @location.nil?
          @location = Location.new
          @location.address = gc.address
          @location.latitude = gc.latitude
          @location.longitude = gc.longitude
          @location.save!
      end
      if current_user.rels(type: :places, between: @location).blank?
        current_user.places << @location
        current_user.save!
      end
  end

  def loc_users
    @users = current_user.places.users
    u = User.find(1158)
    loc = Location.find(1155)
    loc.places.gender_filter('female').to_a
    
  end

  def search_criteria
  @friends = []
    location_ids = params[:location_ids]#.map(&:to_i)
    session['location_ids'] = location_ids
    @friends = User.as(:u).places(:l).where(address: location_ids).limit(2).pluck('DISTINCT u')
    #query = Neo4j::Session.query.match(u: :User, l: :Location)
    #query = query.where('u.id' => current_user.neo_id)  
    #query = query.where('l.neo_id' => location_ids)  
    #@friends = query.where('l.id' => location_ids).pluck('DISTINCT u')
    #@friends = @friends - Array(current_user)
  end

  def page_search_criteria
     @friends = []
    location_ids = session['location_ids']
    @friends = User.as(:u).places(:l).where(address: location_ids).skip((2) * params[:page].to_i-2).limit(2).pluck('DISTINCT u')
   # @friends = @friends - Array(current_user)
  end

  def likes
    @user = User.find(params[:id])
    unless  current_user.rels(type: :likes, between: @user).blank?
      rel = current_user.rels(type: :likes, between: @user)
      rel[0].destroy
      current_user.save!
    else
      current_user.likes << @user
      current_user.save!
    end
    @likes_count = @user.rels(dir: :incoming, type: "likes").count
    #, :content_type => 'text/html'
  end

  def like_list
    @friends = []
    @friends = current_user.likes.limit(2)
  end

  def page_like_list
    @friends = []
    @friends = current_user.likes.skip((2) * params[:page].to_i-2).limit(2)
  end

  def badges
      badges = params[:badges]
        @user = User.find(params[:user_id])
      #  @rel = current_user.badges(:u, :r).where( uuid: @user.uuid ).pluck(:r)
      #  @badges = @rel.map {|b| b.badgeType}.uniq

    @my_badges = []
    if current_user.uuid != @user.uuid
        current_user.rels(dir: :outgoing, type: :badges, between: @user).each do |r|
        #current_user.badges(:u, :r).where( uuid: @user.uuid ).each_with_rel do |u, r| 
        @my_badges << r[:badgeType]
      end

    create_destroy_badges(@my_badges, 'hot', params[:hot], @user)
    create_destroy_badges(@my_badges, 'smart', params[:smart], @user)
    create_destroy_badges(@my_badges, 'macho', params[:macho], @user)
    create_destroy_badges(@my_badges, 'moody', params[:moody], @user)
    create_destroy_badges(@my_badges, 'kind', params[:kind], @user)
    create_destroy_badges(@my_badges, 'stingy', params[:stingy], @user)

    @badges_count = @user.rels(dir: :incoming, type: "badges").count

    @uniq_badges = @user.rels(dir: :incoming, type: :badges).each.map {|r| r.badgeType}.uniq
    @all_badges = {}
    @uniq_badges.each do |badge|
      @all_badges[badge] = @user.rels(dir: :incoming, type: :badges).each.select{|r| r.badgeType == badge }.count
    end

    end

  end

  def update_status
    current_user.status = params[:value]
    current_user.save!

     respond_to do |format|
      format.html
      format.json { render json: current_user }
    end
  end

  def update_about_me
    current_user.about_me = params[:value]
    current_user.save!

     respond_to do |format|
      format.html
      format.json { render json: current_user }
    end
  end

  def add_testimonial
      @user = User.find(params[:id])
      testimonial = Testimonial.new
      testimonial.say = params[:testimonial]
      testimonial.save!

      rel1 = Write_testimonial.create(from_node: current_user, to_node: testimonial)
      rel1.save!

      rel2 = My_testimonial.create(from_node: testimonial, to_node: @user)
      rel2.save!

      @testimonials = @user.testimonials
  end

  def add_picture
    @user = User.find(params[:id])
    @pictures = []
    @pictures << params[:pic]
    @pics = @user.pictures
    if @pics.nil?
      @user.pictures = @pictures
    else
       @user.pictures = nil
        @user.save!
        @pics << @pictures[0]
       @user.pictures =  @pics
    end
    @user.save!

    head :ok

  end

  def pics_edit
    @user = User.find(params[:id])
    @pictures = @user.pictures
  end

  def set_default_pic
    @user = User.find(params[:id])
    @user.default_pic = params[:default_pic]
    @user.save!

  end

  def set_visible_pic
    @user = User.find(params[:id])
     @v_pics = @user.visible_pictures
     @user.visible_pictures = nil
     @user.save!
    if params[:status] == 'true'
      @v_pics << params[:visible_pic]
      @user.visible_pictures = @v_pics
    else
      @v_pics.delete(params[:visible_pic])
      @user.visible_pictures = @v_pics
    end
    @user.save!

    head :ok
  end

end
