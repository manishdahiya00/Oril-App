class Admin::ReportedReelsController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"
  def index
    @reported_reels = ReportedReel.all.paginate(page: params[:page],per_page: 20).order(created_at: :desc)
  end
  def show
    @reel = Reel.find(params[:id])
  end
  def destroy
    @reportedReel = ReportedReel.find(params[:id])
    @reel = Reel.find(@reportedReel.reel_id)
    @reel.comments.destroy_all
    Like.where(reel_id: @reel.id).destroy_all
    @reel.destroy
    @reportedReel.destroy
    redirect_to admin_reported_reels_path, notice: 'Reel was successfully deleted.'
  end

  def approveReel
    @reportedReel = ReportedReel.find(params[:id])
    @reel = Reel.find(@reportedReel.reel_id)
    @reel.update(isReported: false,report_count: 0)
    @reportedReel.destroy
    redirect_to admin_reported_reels_path, notice: 'Reel was successfully deleted.'
  end
end
