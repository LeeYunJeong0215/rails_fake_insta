class Post < ActiveRecord::Base
  mount_uploader :postimage, PostImageUploader
end
