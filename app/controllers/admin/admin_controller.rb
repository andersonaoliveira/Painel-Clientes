class Admin::AdminController < ApplicationController
  before_action :only_admins

  private

  def only_admins
    redirect_to root_path unless current_admin
  end
end
