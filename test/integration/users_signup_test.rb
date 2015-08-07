require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
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


	test "valid signup information" do
		get signup_path
		assert_difference 'User.count', 1 do
			post_via_redirect users_path, user: { name: "Example User",
									 email: "example@example.com",
									 password: "password123",
									 password_confirmation: "password123" }
		end
	assert_template 'users/show'
	assert is_logged_in?
	# nil returns if no flash messages are printed.
	assert_not flash.nil?

	end
end
