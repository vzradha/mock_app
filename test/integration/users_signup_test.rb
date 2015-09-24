require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

	def setup
		ActionMailer::Base.deliveries.clear		
	end
  
	test "invalid signup information"  do
		get signup_path
		assert_no_difference 'User.count' do
			post users_path, user: { name: "",
								   email: "user@invalid",
								   password: "foo",
								   password_confirmation: "bar" }
		end
		assert_template 'users/new'
		assert_select '#error_explanation'
		assert_select '.field_with_errors'
	end


	test "valid signup information account activation" do
		get signup_path
		assert_difference 'User.count', 1 do
			# post_via_redirect users_path, user: { name: "Example User",
			# 						 email: "example@example.com",
			# 						 password: "password123",
			# 						 password_confirmation: "password123" }
		post users_path, user: { name: "Example User",
								 email: "example@example.com",
								 password: "password123",
								 password_confirmation: "password123"}
		end

		assert_equal 1, ActionMailer::Base.deliveries.size
		user = assigns(:user)
		assert_not user.activated?
		#Try to login before activation
		log_in_as(user)
		assert_not is_logged_in?

		#Invalid activation token
		get edit_account_activation_path("invalid token")
		assert_not is_logged_in?

		#valid token, wrong email
		get edit_account_activation_path(user.activation_token, email: 'wrong')
		assert_not is_logged_in?

		#valid activation token
		get edit_account_activation_path(user.activation_token, email:user.email)
		assert user.reload.activated?
		follow_redirect!
		assert_template 'users/show'
		assert is_logged_in?
	# nil returns if no flash messages are printed.
	#assert_not flash.nil?

	end
end
