module API
  module V1
    class Home < Grape::API
      include API::V1::Defaults

      resource :homeForYou do
        before {api_params}


        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              ActiveStorage::Current.url_options = { host:"http://192.168.1.32:8000" }
              reels = []
              User.where.not(id: user.blocked_users.pluck(:blocked_user)).each do |reel_user|
                reel_user.reels.where(isReported: false).each do |reel|
                  creator = User.find(reel.creater_id)
                  isLiked = user.likes.find_by(reel_id: reel.id).present?
                  reels << {
                     reelId: reel.id,
                     allowComments: reel.allow_comments,
                     videoUrl: reel.video.url,
                     isLiked: isLiked,
                     reelDescription: reel.description,
                     musicTitle: reel.music&.title || nil,
                     musicId: reel.music&.id || nil,
                     likes: reel.like_count,
                     comments: reel.comments.count,
                     creatorId: creator.id,
                     creatorName: creator.social_name,
                     creatorImageUrl: creator.social_img_url,
                     isVerified: creator.is_verified,
                     profileCategory: creator.category,
                     shareUrl:  "Hi, I am using this Amazing & Wonderful App to get rid of my Boredom in the Leisure Time. Download & Try this App. Click here: #{BASE_URL}/reels/#{reel.id}/?inviteBy=#{creator.refer_code}",
                  }
                end
              end
            { status: 200, message: "Success", reels: reels }
            else
            { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - homeForYou - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :homeFollowing do

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              popularCreators = []
              popular_creators = User.with_follower_count.order('follower_count DESC').where.not(id: 999).where.not(id: user.blocked_users.pluck(:blocked_user))
              popular_creators.each do |creator|
                popularCreators << {
                  creatorId: creator.id,
                  creatorFullName: creator.social_name,
                  creatorUserName: creator.user_name,
                  creatorImageUrl: creator.social_img_url,
                  isVerified: creator.is_verified,
                }
              end
              { status: 200, message: "Success", users: popularCreators || [] }
            else
              { status: 500, message: "User Not Found"}
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - homeFollowing - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end



      resource :notificationList do

        params do
          use :common_params
          requires :page, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              data = {}
              notificationsList = []
              user.notifications.where.not(creator_id: user.id).order(created_at: :desc).paginate(page: params[:page], per_page: 12).each do |notification|
                puts notification.id
                user = User.find(notification.creator_id)
                notificationsList << {
                  id: notification.id,
                  creatorId: user.id,
                  creatorFullName: user.social_name,
                  creatorImageUrl: user.social_img_url,
                  NotificationType: notification.notification_type,
                  NotificationContent: notification.content,
                  reelId: notification.reel_id || 0
                }
              end
              data[:notificationList] = notificationsList
              puts notificationsList.to_s
              { status: 200, message: "Success", data: data || {} }
            else
              { status: 500, message: "User Not Found"}
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - notificationList - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


    end
  end
end
