class Write_testimonial 
	include Neo4j::ActiveRel

  from_class User
  to_class   Testimonial
  type 'write_testimonials'

end
