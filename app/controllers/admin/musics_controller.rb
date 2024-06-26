class Admin::MusicsController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"

  def index
    @musics = Music.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def show
    @music = Music.find(params[:id])
  end

  def new
    @music = Music.new
  end

  def create
    @music = Music.new(music_params)

    if @music.save
      redirect_to admin_music_path(@music), notice: 'Music was successfully created.'
    else
      render :new
    end
  end

  def edit
    @music = Music.find(params[:id])
  end

  def update
    @music = Music.find(params[:id])

    if @music.update(music_params)
      redirect_to admin_music_path(@music), notice: 'Music was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @music = Music.find(params[:id])
    @music.destroy

    redirect_to admin_musics_path, notice: 'Music was successfully destroyed.'
  end

  private

  def music_params
    params.require(:music).permit(:title, :music_url, :image_url, :singer)
  end
end
