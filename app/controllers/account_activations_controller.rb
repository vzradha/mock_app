class AccountActivationsController < ApplicationController

	def edit
		user = User.find_by(email: params[:email])
		if user && !user.activated? &&  user.authenticated?(:activation, params[:id])
			# user.update_attribute(:activated, true)
			# user.update_attribute(:activated_at, Time.zone.now)
			user.activate #refactored the above 2 lines in the user model with activate function
			log_in user
			flash[:success] = "Account Activated"
			redirect_to user
		else
			flash[:danger] = "Invalid Activation link"
			redirect_to root_url
		end		
	end
end
