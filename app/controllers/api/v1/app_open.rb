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
              if user.last_check_in.nil? || user.last_check_in < 24.hours.ago
                wallet_balance = user.wallet_balance + 5
                check_in_balance = user.check_in_balance + 5
                user.update(wallet_balance: wallet_balance,last_check_in: Time.now,check_in_balance: check_in_balance)
              end
              { status: 200, message: "Success", appUrl: "", forceUpdate: false, socialEmail: user.social_email, socialImgUrl: user.social_img_url, sociaName: user.social_name, coinList: COIN_LIST, profileCategory: PROFILE_CATEGORY }
            else
              { status: 500, message: "User Not Found", error: e }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - appOpen - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end
    end
  end
end
