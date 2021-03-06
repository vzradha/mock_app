class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy # dependent: :destroy kills microposts when a user is destroyed.
	has_many :active_relationships, class_name: "Relationship",
									foreign_key: "follower_id",
									dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship",
									 foreign_key: "followed_id",
									 dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower
	attr_accessor :remember_token, :activation_token, :reset_token
	before_save   :downcase_email
	before_create :create_activation_digest

	validates :name, presence: true, length: { maximum: 35 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true , length: { maximum: 255 },
							 format: { with: VALID_EMAIL_REGEX},
							 uniqueness: {case_sensitive: false}
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
													  BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)						
	end


	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def remember
		self.remember_token
		update_attribute(:remember_digest, User.digest(remember_token))	
	end

	# def authenticated?(remember_token)
	# 	digest = user.send('remember_digest')
	# 	return false if remember_digest.nil?
	# 	BCrypt::Password.new(remember_digest).is_password?(remember_token)
		
	# end
	
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end


	def forget
		update_attribute(:remember_digest, nil)
		
	end

	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now		
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)		
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now		
	end

	#Returns true if a password reset has expired
	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end
	
	#Returns a users status feed
	
	def feed
		#pulls all microposts from all the following ids..inefficient
		#Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
		following_ids = "SELECT followed_id FROM relationships where follower_id = :user_id"
		Micropost.where("user_id IN (#{ following_ids}) OR user_id = :user_id", following_ids: following_ids, user_id: id)
	end

	#Define proto-feed
	#Feed on users profile page and following users, uses the where method
	#? escapes id to avoid sql injection
	def feed
		Micropost.where("user_id = ?", id)
	end

	#follows a user
	def follow(other_user)
		active_relationships.create(followed_id: other_user.id)
	end

	#unfollows a user
	def unfollow(other_user)
		active_relationships.find_by(followed_id: other_user.id).destroy
	end
	#Boolean to return true if current user is following other user
	def following?(other_user)
		following.include?(other_user)
	end
	private 

	def downcase_email
		self.email = email.downcase
	end

	def create_activation_digest
		#create token and digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)		
	end

end
