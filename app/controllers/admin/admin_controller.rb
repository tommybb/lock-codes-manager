module Admin
  class AdminController < ApplicationController
    before_action :check_admin

    private

    def check_admin
      unless current_user.admin?
        redirect_to root_path, alert: 'You have to be logged in as admin to see this page.'
      end
    end
  end
end
