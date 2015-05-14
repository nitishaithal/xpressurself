class Friend_boy
	include Neo4j::ActiveRel
	property :provider, :type => String

	from_class User
  	to_class   User
  	type 'friend_boys'

end
