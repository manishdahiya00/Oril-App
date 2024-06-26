module Admin
	class DashboardController < Admin::AdminController
		layout "admin"
	def index
		@users = User.count
		@reels = Reel.count
		@musics = Music.count
	end
end
end
