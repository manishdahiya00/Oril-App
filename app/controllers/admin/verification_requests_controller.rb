class Admin::VerificationRequestsController < Admin::AdminController
  before_action :authenticate_user!
  layout 'admin'

  def index
    @verification_requests = VerificationRequest.all.paginate(page: params[:page],per_page: 20).order(created_at: :desc)
  end

  def show
    @verification_request = VerificationRequest.find(params[:id])
  end

  def verifyUser
    @verification_request = VerificationRequest.find(params[:id])
    @user = User.find(@verification_request.user_id)
    if @user.is_verified == false
    @verification_request.update(status: "Verified")
    @user.update(is_verified: true,status: @verification_request.status)
    redirect_to admin_verification_requests_path, notice: 'Verification request was successfully verified.'
    else
    @verification_request.update(status: "Verification Request")
    @user.update(is_verified: false,status: @verification_request.status)
    redirect_to admin_verification_requests_path, notice: 'Verification request was successfully verified.'
    end
  end
end
