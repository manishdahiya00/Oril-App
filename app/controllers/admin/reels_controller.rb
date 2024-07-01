class Admin::ReelsController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"

  def index
    @reels = Reel.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def show
    @reel = Reel.find(params[:id])
  end

  def new
    @reel = Reel.new
    @users = User.limit(10)
  end

  def create
    @reel = Reel.new(reel_params)

    if @reel.save
      redirect_to admin_reel_path(@reel), notice: "Reel was successfully created."
    else
      @users = User.limit(10)
      render :new
    end
  end

  def edit
    @reel = Reel.find(params[:id])
    @users = User.limit(10)
  end

  def update
    @reel = Reel.find(params[:id])

    if @reel.update(reel_params)
      redirect_to admin_reel_path(@reel), notice: "Reel was successfully updated."
    else
      @users = User.limit(10)
    end
  end

  def destroy
    @reel = Reel.find(params[:id])
    @reel.destroy
    redirect_to admin_reels_path, notice: "Reel was successfully deleted."
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

  private

  def reel_params
    params.require(:reel).permit(:music_id, :description, :hastags, :videoUrl, :allow_comments, :creater_id, :isReported, :is_approved, :category)
  end
end
