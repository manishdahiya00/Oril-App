class Admin::PayoutsController < Admin::AdminController
  before_action :authenticate_user!
  before_action :set_payout, only: [:show, :edit, :update, :destroy]
  layout "admin"


  def index
    @payouts = Payout.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def show
  end

  def new
    @payout = Payout.new
  end

  def edit
  end

  def create
    @payout = Payout.new(payout_params)
    if @payout.save
      redirect_to admin_payout_path(@payout), notice: 'Payout was successfully created.'
    else
      render :new
    end
  end

  def update
    if @payout.update(payout_params)
      redirect_to admin_payout_path(@payout), notice: 'Payout was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @payout.destroy
    redirect_to admin_payouts_url, notice: 'Payout was successfully destroyed.'
  end

  private

  def set_payout
    @payout = Payout.find(params[:id])
  end

  def payout_params
    params.require(:payout).permit(:payout_name, :payout_img_url, :payout_amount)
  end
end
