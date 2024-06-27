class Admin::DeleteRequestsController < Admin::AdminController
  before_action :authenticate_user!
  layout 'admin'

  def index
    @delete_requests = DeleteRequest.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def destroy
    @delete_request = DeleteRequest.find(params[:id])
    @user = User.find(@delete_request.user_id)

    if @user .present?
      @user.destroy
      @delete_request.destroy
      @user.likes.destroy_all
      @user.fav_musics.destroy_all
      @user.blocked_users.destroy_all
      @user.notifications.destroy_all
      @user.orders.destroy_all
      @user.redeems.destroy_all
      @user.transactions.destroy_all
      Follow.where(follower_id: @user.id).destroy_all
      Follow.where(following_id: @user.id).destroy_all
      redirect_to admin_delete_requests_path, notice: 'User and delete request were successfully deleted.'
    else
      redirect_to admin_delete_requests_path, alert: 'Failed to delete user and delete request.'
    end
  end
end
