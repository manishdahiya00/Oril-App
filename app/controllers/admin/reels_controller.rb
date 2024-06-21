class Admin::ReelsController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"

  def index
    @reels = Reel.all.paginate(page: params[:page], per_page: 20)
  end

  def show
    @reel = Reel.find(params[:id])
  end

  def approveReel
    @reel = Reel.find(params[:id])
    if @reel.is_approved
      @reel.update(is_approved: false)
    else
      @reel.update(is_approved: true)
    end
    redirect_to admin_reels_path, notice: "Reel approval status updated."
  end
end
