class Photo
    include Neo4j::ActiveNode

  property :pic, :type => String
  mount_uploader :pic, PhotoUploader

  
#  has_attached_file :pic,  :url =>
#"/images/photos/:id/:style_:basename.:extension", :path =>
#":rails_root/public/images/photos/:id/:style_:basename.:extension"

 # validates_attachment_content_type :pic, :content_type =>
#'image/jpeg', :message => "has to be in jpeg format"


  #,
  #:storage => :s3,
  #:s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
  #:path => ":attachment/:id/:style.:extension",
  #:bucket => 'yourbucket'

end
