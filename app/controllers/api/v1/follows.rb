module API
  module V1
    class Follows < Grape::API
      include API::V1::Defaults

      resource :followCreator do
        before {api_params}

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              creator = User.find(params[:creatorId])
              if creator.present?
                isFollowed = Follow.find_by(follower_id: params[:userId], following_id: params[:creatorId])
                if isFollowed.present?
                    isFollowed.destroy
                    { status: 200, message: "Success", data: "#{creator.user_name} removed from following list" }
                else
                  Follow.create(follower_id: params[:userId], following_id: params[:creatorId])
                  Notification.create(user_id: params[:creatorId],creator_id: params[:userId],content: "#{user.user_name} stated following you",notification_type: "follow")
                  { status: 200, message: "Success", data: "#{creator.user_name} added to following list" }
                end
              else
              { status: 500, message: "Creator Not Found" }
              end
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - follow - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end


    end
  end
end
