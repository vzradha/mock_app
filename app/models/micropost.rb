class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #default_scope is used to order rows from db, here we order microposts in descending order
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size # the validate keyword is used for custom validations


	private
	#Validate the size of the picture uploaded
	def picture_size
		if picture.size > 5.megabytes
			errors.add(:picture, "Too Large")
		end
	end
end
