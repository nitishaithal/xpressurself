class FbWorker
	include Sidekiq::Worker

	#def import_friends(uid)
	#	@user = User.find_by(uid: uid)
	#	@friends = @user.friends_list
	#	create_fb_friends(@user, @friends)
	#end

	 def perform(uid, f_uid, f_name)
        user = User.find_by(uid: uid)
	 	facebook = Koala::Facebook::API.new(user.fb_access_token)
                @new_user = User.find_by(uid: f_uid)
                unless @new_user.present?
                  @new_user = User.new
                  @new_user.uid = f_uid
                  @new_user.name = f_name
                  @new_user.save

                  user.friends << @new_user
                    if facebook.get_object(f_uid)['gender'] == 'male'
                      user.friend_boys << @new_user
                    else
                      user.friend_girls << @new_user
                    end
                    user.save!


                else
               if  user.rels(type: :friends, between: @new_user).blank?
                    user.friends << @new_user
                    if facebook.get_object(f_uid)['gender'] == 'male'
                      user.friend_boys << @new_user
                    else
                      user.friend_girls << @new_user
                    end
                    user.save!
                  end
                end
  	end
end