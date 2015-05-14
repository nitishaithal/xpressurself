class Testimonial 
	include Neo4j::ActiveNode
	property :say, :type => String


  has_many :in, :write_testimonials, model_class: User,  rel_class: Write_testimonial
  has_many :in, :like_testimonials, model_class: User,  rel_class: Like_testimonial
  has_many :out, :testimonials, model_class: User,  rel_class: My_testimonial

end
