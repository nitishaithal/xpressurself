class Badge 
	include Neo4j::ActiveRel
	property :badgeType, :type => String
	property :pic, :type => String

  from_class User
  to_class   User
  type 'badges'

end
