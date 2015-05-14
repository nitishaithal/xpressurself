class Visit 
	include Neo4j::ActiveRel
	property :count, type: Integer, default: 0
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  from_class User
  to_class   User
  type 'visits'

end
