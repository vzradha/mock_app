require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
  	@user = User.new(name: "Example user", email: "user@example.com",
  					 password: "foobar", password_confirmation: "foobar")
   end

   test "should be valid" do
   		assert @user.valid?
   	end

   	test "name should be present" do
   		@user.name = "   "
   		assert_not @user.valid?
   	end

   	test "email should be present" do
   		@user.email = "   "
   		assert_not @user.valid?
   	end

   	test "name shoundn't be too long" do
   		@user.name = "a" * 36
   		assert_not @user.valid?
   	end

   	test "email shouldn't be too long" do
   		@user.email = "a" * 244 + "@example.com"
   		assert_not @user.valid?
   	end

   	test "email address validation" do
   		valid_addresses = %w[user@example.com  US-Er@user.com A_UsEr@foo.org first.last@bar.jp alice+bob@test.com]
   		valid_addresses.each do  |valid_address|
   			@user.email = valid_address
   			assert @user.valid?, "#{valid_address.inspect} should be valid"
   		end
   	end


   	test "email address invalidation" do
   		invalid_addresses = %w[user@example,com THE US-Er@user_com A_UsEr@foo. first.last@bar_baz.jp alice+bob@test+com]
   		invalid_addresses.each do  |invalid_address|
   			@user.email = invalid_address
   			assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
   		end
   	end

   	test "unique email address" do
   		duplicate_user = @user.dup
   		duplicate_user.email = @user.email.upcase
   		@user.save
   		assert_not duplicate_user.valid?
   	end

   	test "password should be present (non blank)" do
   		@user.password = @user.password_confirmation = " " * 6 
   		assert_not @user.valid?
   	end

   	test "password should have min length" do
   		@user.password = @user.password_confirmation = "a" * 5
   		assert_not @user.valid?
   	end

      test "authenticated? should return false for a user with nil digest" do
         assert_not @user.authenticated?(:remember, '')
      end

     #Create an user to get an id, create a micropost and check if the micropost count reduces when the user is destroyed.

      test "associated microposts are also destroyed" do
         @user.save
         @user.microposts.create!(content: "Loren Ipsum")
         assert_difference 'Micropost.count', -1 do
            @user.destroy
         end
      end
	  #Following and unfollowing test
	  test "should follow and unfollow a user" do
		  valli = users(:valli)
		  pattu = users(:pattu)
		  assert_not valli.following?(pattu)
		  valli.follow(pattu)
		  assert valli.following?(pattu)
		  assert pattu.followers.include?(valli)
		  valli.unfollow(pattu)
		  assert_not valli.following?(pattu)
	end
end



