class Admin::UsersController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"

  def index
    @users = User.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
    @reels = @user.reels.all.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
    @transactions = @user.transactions.all.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
    @orders = @user.orders.all.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
    @redeems = @user.redeems.all.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
  end

  def payout
    @redeem = Redeem.find(params[:payout_id])
    @user = User.find(@redeem.user_id.to_i)
    if params[:secret] == "5555"
      if @redeem.update(status: "COMPLETED")
        redirect_to admin_user_path(@user), notice: "Payout Successful"
      else
        redirect_to admin_user_path(@user), notice: "Payout failed: #{@redeem.errors.full_messages.join(", ")}"
      end
    else
      redirect_to admin_user_path(@user), alert: "Invalid Secret Code"
    end
  end
end
