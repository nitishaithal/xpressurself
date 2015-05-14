class User 
  include Neo4j::ActiveNode

  property :name, :type => String, :index => :exact
  property :mood, :type => String
  property :status, :type => String
  property :dob, :type => DateTime, :index => :exact
  property :uid, :type => String, :index => :exact, :unique => true
  property :username, :type => String
  property :email, :type => String, :index => :exact
  property :gender, :type => String, :index => :exact
  property :remember_token, :type => String, :index => :exact
  property :fb_access_token, :type => String, :index => :exact
  property :status, :type => String
  property :about_me, :type => String
  property :default_pic, :type => String

  scope :gender_filter, ->(g){ where(gender: g)}

  property :friends_list
  serialize :friends_list

  property :pictures
  serialize :pictures

  property :visible_pictures
  serialize :visible_pictures

  property :fb_pictures
  serialize :fb_pictures


  #before_save :create_remember_token

  validates :email, :uniqueness => true

  has_many :both, :friends,  model_class: User,  rel_class: Friend
  has_many :both, :friend_girls,  model_class: User,  rel_class: Friend_girl
  has_many :both, :friend_boys,  model_class: User,  rel_class: Friend_boy
  has_many :both, :places,  model_class: Location,  rel_class: Place
  has_many :out, :likes, model_class: User,  rel_class: Like
  has_many :both, :badges, model_class: User,  rel_class: Badge
  has_many :out, :write_testimonials, model_class: Testimonial,  rel_class: Write_testimonial
  has_many :out, :like_testimonials, model_class: Testimonial,  rel_class: Like_testimonial
  has_many :in, :testimonials, model_class: Testimonial,  rel_class: My_testimonial
  has_many :out, :profile_pics,  model_class: Picture,  rel_class: Profile
  #has_one :out, :default_pics,  model_class: Picture,  rel_class: Profile
  has_many :out, :visits,  model_class: User,  rel_class: Visit

  #has_one :out, :users_place, type: :users_place, model_class: Location
  #has_n(:friends).to(User).relationship(Friend)
  #has_n(:friend_girls).to(User).relationship(Friend_girl)
  #has_n(:friend_boys).to(User).relationship(Friend_boy)

  def self.create_with_omniauth(auth)
    create! do |user|
      user_details = auth['extra']['raw_info']
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.fb_access_token = auth['credentials']['token']
      user.username = auth['info']['nickname']
      user.email = user_details['email']
      user.gender = user_details['gender']
      #user.dob = DateTime.parse(user_details['birthday'])
      user.remember_token = SecureRandom.urlsafe_base64
    end

    #UserMailer.welcome_email(user).deliver

  end



  def self.paginate(options={})
    page = options[:page] || 1
    per_page = options[:per_page] || 8
   self.skip((per_page-1) * page).limit(per_page)
  end

 private
  def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
  end

end
