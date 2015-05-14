class Like_testimonial 
	include Neo4j::ActiveRel

  from_class User
  to_class   Testimonial
  type 'like_testimonials'

end
