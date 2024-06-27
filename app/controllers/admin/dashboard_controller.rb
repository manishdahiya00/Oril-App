module Admin
	class DashboardController < Admin::AdminController
		layout "admin"
	def index
		@users = User.count
		@reels = Reel.count
		@musics = Music.count
		@reportedReels = ReportedReel.count
		@payouts = Payout.count
		@deleteRequest = DeleteRequest.count
		@verificationRequest = VerificationRequest.count
		@orders = Order.count
	end
end
end
