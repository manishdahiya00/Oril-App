module API
  module V1
    class Auth < Grape::API
      include API::V1::Defaults


      helpers do
        def google_validator(token, socialemail)
                validator = GoogleIDToken::Validator.new(expiry: 300)
                begin
                  token_segments = token.split('.')
                  if token_segments.count == 3
                    # optional_client_id = "511334437597-29pnd8hkorkh186vftvu1dpka58qkq2v.apps.googleusercontent.com"
                    required_audience = JWT.decode(token, nil, false)[0]['aud']
                    payload = validator.check(token, required_audience)
                    # payload = validator.check(token, required_audience, optional_client_id)
                    if(payload['email'] == socialemail) #&& (payload['azp'].include? "511334437597")
                      return true
                    else
                      return false
                    end
                  else
                    return false
                  end
                rescue GoogleIDToken::ValidationError => e
                  return false
                end
              end
        end

      resource :userSignup do
        before { api_params }

        params do
          requires :deviceId, type: String, allow_blank: false
          requires :deviceType, type: String, allow_blank: true
          requires :deviceName, type: String, allow_blank: true
          requires :socialType, type: String, allow_blank: false
          requires :socialId, type: String, allow_blank: false
          requires :socialToken, type: String, allow_blank: false
          requires :socialEmail, type: String, allow_blank: true
          requires :socialName, type: String, allow_blank: true
          requires :socialImgUrl, type: String, allow_blank: true
          requires :advertisingId, type: String, allow_blank: true
          requires :versionName, type: String, allow_blank: false
          requires :versionCode, type: String, allow_blank: false
          requires :utmSource, type: String, allow_blank: true
          requires :utmMedium, type: String, allow_blank: true
          requires :utmTerm, type: String, allow_blank: true
          requires :utmContent, type: String, allow_blank: true
          requires :utmCampaign, type: String, allow_blank: true
          requires :referrerUrl, type: String, allow_blank: true
        end

        post do
          begin
            ip_addr = request.ip
            user = User.find_by(social_email: params[:socialEmail], social_id: params[:socialId])
            genuine_user = google_validator(params[:socialToken], params[:socialEmail])
            if genuine_user
              if user.present?
                { status: 200, message: "Success", userId: user.id, securityToken: user.security_token }
              else
                new_user = User.create(
                  device_id: params[:deviceId],
                  device_type: params[:deviceType],
                  device_name: params[:deviceName],
                  social_type: params[:socialType],
                  social_id: params[:socialId],
                  social_email: params[:socialEmail],
                  user_name: params[:socialEmail].split("@").first,
                  social_name: params[:socialName],
                  social_img_url: params[:socialImgUrl],
                  advertising_id: params[:advertisingId],
                  version_name: params[:versionName],
                  version_code: params[:versionCode],
                  utm_source: params[:utmSource],
                  utm_medium: params[:utmMedium],
                  utm_term: params[:utmTerm],
                  utm_content: params[:utmContent],
                  utm_campaign: params[:utmCampaign],
                  referal_url: params[:referrerUrl],
                  security_token: SecureRandom.uuid,
                  source_ip: ip_addr,
                  refer_code: SecureRandom.hex(6).upcase
                )
                { status: 200, message: "Success", userId: new_user.id, securityToken: new_user.security_token }
              end
            else
              {status:500,message: "Sorry, Tricks are not allowed"}
            end
          rescue => e
            Rails.logger.error "API Exception - #{Time.now} - userSignup - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :defaultUser do

        params do
          requires :email, type: String, allow_blank: false
          requires :password, type: String, allow_blank: false
          requires :versionName, type: String, allow_blank: false
          requires :versionCode, type: String, allow_blank: false
        end

        post do
          begin
            ip_addr = request.ip
            if params[:email] == 'testingyash8@gmail.com' && params[:password] == 'yash@123'
              user = User.find_by(social_email: params[:email])
              if user.present?
                {message: "Success", status: 200, userId: user.id, securityToken: user.security_token}
              else
                new_user = User.create(social_name: "Testing Yash",social_email: params[:email],user_name: params[:email].split("@").first,security_token: "acc7106fe5009609",source_ip: ip_addr,
                refer_code: SecureRandom.hex(6).upcase,social_img_url: "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png")
                {message: "Success", status: 200, userId: new_user.id, securityToken: new_user.security_token}
              end
            else
              {message: "User Not Found", status: 500}
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - defaultUser - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :deleteUser do

        params do
          use :common_params
          requires :reason, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              if user.delete_request.present?
                {message: "Success", status: 200, data: "Your request is already in progress" }
              else
                user.delete_request = DeleteRequest.create(reason: params[:reason])
                {message: "Success", status: 200, data: "Account delete request submitted successfully" }
              end
            else
              {message: "User Not Found", status: 500}
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - deleteUser - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end



    end
  end
end
