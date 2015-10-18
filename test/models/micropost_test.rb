require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
	def setup
		@user = users(:valli)
	#	@micropost = Micropost.new(content: "Loren Ipsum", user_id: @user.id)		# No association to user model.
		@micropost = @user.microposts.build(content: "Loren Ipsum")
	end
##Validaton tests
	test "should be valid" do
		assert @micropost.valid?
	end

	test "user_id should be present" do
		@micropost.user_id = nil
		assert_not @micropost.valid?
	end


	test "content should be present" do
		@micropost.content = " "
		assert_not @micropost.valid?
	end

	test "content should not be more than 140 char" do
		@micropost.content = "a" * 141
		assert_not @micropost.valid?
	end
##

	test "micropost most recent first" do
		assert_equal microposts(:most_recent), Micropost::first
	end

end
