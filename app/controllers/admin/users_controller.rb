  class Admin::UsersController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"
    def index
      @users = User.all.paginate(page: params[:page],per_page: 20).order(created_at: :desc)
    end
    def show
      @user = User.find(params[:id])
    end
  end
