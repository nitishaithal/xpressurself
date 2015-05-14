class Picture 
  include Neo4j::ActiveNode

  property :visible, :type => Boolean, :index => :exact
  property :url, :type => String, :index => :exact

  has_one :in, :profile_pics,  model_class: User,  rel_class: Profile

end
