Rails.application.config.middleware.use OmniAuth::Builder do
 provider :facebook, FACEBOOK_CONFIG['FACEBOOK_APP_ID'], FACEBOOK_CONFIG['FACEBOOK_SECRET'], :scope => 'user_friends,email,user_birthday,read_stream,user_photos,read_friendlists '


end

