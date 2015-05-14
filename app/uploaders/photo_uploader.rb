# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base
    include Cloudinary::CarrierWave
  #include CarrierWave::MiniMagick

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
   include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  #storage :file
  # storage :s3
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :resize_to_limit => [1200, 800]

  cloudinary_transformation :quality => 70
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :tiny do
     cloudinary_transformation :width =>15, :height => 15, :crop => :fill, :gravity => :faces
   end 

  version :tiny_logo do
     process :resize_to_fit => [350, 25]
   end 

  version :smallest_fit do
     process :resize_to_fit => [350, 25]
   end 


  version :smallest_half do
     cloudinary_transformation :width =>25, :height => 25, :crop => :fill, :gravity => :faces
   end 
  version :smallest do
     cloudinary_transformation :width =>50, :height => 50, :crop => :fill, :gravity => :faces
   end 
   version :smaller_mid do
     cloudinary_transformation :width =>75, :height => 75, :crop => :fill, :gravity => :faces
   end 

  version :smaller do
         cloudinary_transformation :width =>100, :height => 100, :crop => :fill, :gravity => :faces
   end 
  version :small_mid do
         cloudinary_transformation :width =>125, :height => 125, :crop => :fill, :gravity => :faces
   end

  version :small do
     cloudinary_transformation :width => 150, :height => 150, :crop => :fill, :gravity => :faces
   end 
  version :comm_img do
    cloudinary_transformation :width => 50, :height => 50, :crop => :fill, :gravity => :faces, :radius => :max
   end 
   version :thumb do
    cloudinary_transformation :width => 200, :height => 200, :crop => :fill, :gravity => :faces
   end 
    version :thumb_half_medium do
    cloudinary_transformation :width => 225, :height => 225, :crop => :fill, :gravity => :faces
   end 
   version :thumb_medium do
    cloudinary_transformation :width => 250, :height => 250, :crop => :fill, :gravity => :faces
   end 
   version :medium do
     process :resize_to_fit => [370, 370]
   end
   version :medium_large do
     process :resize_to_fit => [500, 500]
   end
   version :large_mid do
     cloudinary_transformation :width => 545, :height => 350, :crop => :fill, :gravity => :faces
   end
   version :cu_large_mid do
     cloudinary_transformation :width => 557, :height => 250, :crop => :fill, :gravity => 'faces:center'
   end
   version :largest do
     cloudinary_transformation :width => 910, :height => 320, :crop => :fill, :gravity => 'faces:center'
   end   
   version :large do
     process :resize_to_fit => [650, 650]
   end
   version :cover_pic_smallest_mid do
     process :resize_to_fit => [50, 300]
   end
   version :cover_pic_smallest do
     process :resize_to_fit => [75, 300]
   end
   
  version :cover_pic_smaller do
     process :resize_to_fit => [175, 400]
   end
  version :cover_pic_small do
     process :resize_to_fit => [350, 400]
   end

   version :photogrid_one do
     cloudinary_transformation :width => 545, :height => 350, :crop => :fill, :gravity => :faces
   end

   version :photogrid_two do
     cloudinary_transformation :width => 271, :height => 175, :crop => :fill, :gravity => :faces
   end
   version :photogrid_three_one do
     cloudinary_transformation :width => 335, :height => 350, :crop => :fill, :gravity => :faces
   end

   version :photogrid_three_two do
     cloudinary_transformation :width => 210, :height => 173, :crop => :fill, :gravity => :faces
   end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
   def extension_white_list
     %w(jpg jpeg gif png bmp)
   end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

    # Generate a 164x164 JPG of 80% quality 
  version :simple do
    process :resize_to_fill => [164, 164, :fill]
    process :convert => 'jpg'
    cloudinary_transformation :quality => 80
  end
  
  # Generate a 100x150 face-detection based thumbnail, 
  # round corners with a 20-pixel radius and increase brightness by 30%.
  version :bright_face do
    cloudinary_transformation :effect => "brightness:30", :radius => 20,
      :width => 100, :height => 150, :crop => :thumb, :gravity => :faces
  end

  # Apply an incoming chained transformation: limit image to 1000x1200 and 
  # add a 30-pixel watermark 5 pixels from the south east corner.   
 # cloudinary_transformation :transformation => [
  #    {:width => 1000, :height => 1200, :crop => :limit}, 
   #   {:overlay => "my_watermark", :width => 30, :gravity => :south_east, 
    #   :x => 5, :y => 5}
   # ]        
  
  # Eagerly transform image to 150x200 with a sepia effect applied and then
  # rotate the resulting image by 10 degrees. 
  version :rotated do
    eager
    cloudinary_transformation :transformation => [
        {:width => 150, :height => 200, :crop => :fill, :effect => "sepia"}, 
        {:angle => 10}
      ]
  end

  version :full do    
    process :convert => 'jpg'
    process :custom_crop
  end    
  
  def custom_crop      
    return :x => model.crop_x, :y => model.crop_y, 
      :width => model.crop_width, :height => model.crop_height, :crop => :crop      
  end

end
