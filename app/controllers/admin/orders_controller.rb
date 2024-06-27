class Admin::OrdersController < Admin::AdminController
  before_action :authenticate_user!
  layout 'admin'

  def index
    @orders = Order.all.paginate(page: params[:page],per_page: 20).order(created_at: :desc)
  end

end
