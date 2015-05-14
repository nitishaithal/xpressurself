class Profile 
	include Neo4j::ActiveRel
	property :visible, :type => Boolean

  from_class User
  to_class   Picture
  type 'profile_pics'

end
