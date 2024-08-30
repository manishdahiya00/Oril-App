module API
  module V1
    class CricketReels < Grape::API
      include API::V1::Defaults

      resource :cricketReels do
        before { api_params }

        params do
          use :common_params
          requires :page, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if !user.present?
              { status: 500, message: "Error" }
            else
              @reels = Reel.where("description LIKE ?", "%cricket%").paginate(page: params[:page], per_page: 10)
              { status: 200, message: "Success", reels: @reels || [] }
            end
          rescue => e
            Rails.logger.error "API Exception - #{Time.now} - userSignup - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end
    end
  end
end
