class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    @users = User.all
  end

  private

  def is_admin?
    redirct_to '/' and return unless current_user.admin?
  end
end
