class Place 
	include Neo4j::ActiveRel
	property :placetype, :type => String

  from_class User
  to_class   Location
  type 'places'

end
