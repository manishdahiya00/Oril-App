module API
  module V1
    class AppOpen < Grape::API
      include API::V1::Defaults

      resource :appOpen do
        before {api_params}

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              { status: 200, message: "Success", appUrl: "", forceUpdate: false, socialEmail: user.social_email, socialImgUrl: user.social_img_url, sociaName: user.social_name, coinList: COIN_LIST, profileCategory: PROFILE_CATEGORY }
            else
              { status: 500, message: "User Not Found", error: e }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - appOpen - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end
    end
  end
end
