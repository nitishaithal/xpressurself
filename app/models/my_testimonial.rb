class My_testimonial 
	include Neo4j::ActiveRel

  from_class Testimonial
  to_class   User
  type 'testimonials'

end
