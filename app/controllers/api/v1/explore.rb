module API
  module V1
    class Explore < Grape::API
      include API::V1::Defaults

      resource :explore do
        before { api_params }

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              popularCreators = []
              popularHashtags = []
              popular_creators = User.with_follower_count.order("follower_count DESC").where.not(id: user.blocked_users.pluck(:blocked_user)).where.not(id: params[:userId]).limit(10)
              popular_creators.each do |creator|
                popularCreators << {
                  creatorId: creator.id,
                  creatorFullName: creator.social_name,
                  creatorUserName: creator.user_name,
                  creatorImageUrl: creator.social_img_url,
                  isVerified: creator.is_verified,
                  followersCount: creator.followers.where.not(id: user.blocked_users.pluck(:blocked_user)).count,
                }
              end
              POPULAR_HASHTAGS = ["trending", "motivation", "love", "funny", "travel"]
              POPULAR_HASHTAGS.each do |hashtag|
                case hashtag
                when "trending"
                  reels = Reel.where(isReported: false, is_approved: true, category: "trending")
                when "motivation"
                  reels = Reel.where(isReported: false, is_approved: true, category: "motivation")
                when "love"
                  reels = Reel.where(isReported: false, is_approved: true, category: "love")
                when "funny"
                  reels = Reel.where(isReported: false, is_approved: true, category: "funny")
                when "travel"
                  reels = Reel.where(isReported: false, is_approved: true, category: "travel")
                else
                  reels = []
                end
                reels = reels.where.not(creater_id: user.blocked_users.pluck(:blocked_user))
                             .order(like_count: :desc)
                             .limit(5)
                reels_data = reels.map do |reel|
                  {
                    reelId: reel.id,
                    reelUrl: reel.videoUrl,
                  }
                end
                popularHashtags << {
                  hashName: hashtag,
                  hashData: reels_data,
                }
              end
              { status: 200, message: "Success", popularCreators: popularCreators || [], hashtags: popularHashtags || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - explore - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :search do
        before { api_params }

        params do
          use :common_params
          requires :category, type: String, allow_blank: true
          requires :keyword, type: String, allow_blank: true
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              data = {}
              if params[:category].present?
                userList = []
                reelList = []
                category_searched_users = User.where(category: params[:category]).where.not(id: user.blocked_users.pluck(:blocked_user)).limit(20)
                category_searched_users.each do |user|
                  userList << {
                    creatorId: user.id,
                    creatorImageUrl: user.social_img_url,
                    fullName: user.social_name,
                    userName: user.user_name,
                    isVerified: user.is_verified,
                    followersCount: user..followers.where.not(id: user.blocked_users.pluck(:blocked_user)).count,
                    likesCount: user.reels.where(isReported: false, is_approved: true).sum(:like_count),
                  }
                end
                category_searched_reels = Reel.where(isReported: false, is_approved: true).where.not(creater_id: user.blocked_users.pluck(:blocked_user)).order(like_count: :desc).joins(:user).where(user: { category: params[:category] }).limit(20)
                category_searched_reels.each do |reel|
                  creator = User.find(reel.creater_id)
                  reelList << {
                    reelId: reel.id,
                    video_url: reel.videoUrl,
                    viewCount: reel.view_count,
                  }
                end
                data[:userList] = userList || []
                data[:reelList] = reelList || []
              elsif params[:keyword].present?
                userList = []
                reelList = []
                keyword_searched_users = User.where("LOWER(user_name) LIKE ? OR LOWER(social_name) LIKE ?", "%#{params[:keyword].downcase}%", "%#{params[:keyword].downcase}%").where.not(id: user.blocked_users.pluck(:blocked_user)).limit(20)
                keyword_searched_reels = Reel.where(isReported: false, is_approved: true).where.not(creater_id: user.blocked_users.pluck(:blocked_user)).where("LOWER(hastags) LIKE ? OR LOWER(description) LIKE ?", "%#{params[:keyword].downcase}%", "%#{params[:keyword].downcase}%").limit(20)
                keyword_searched_users.each do |user|
                  userList << {
                    creatorId: user.id,
                    creatorImageUrl: user.social_img_url,
                    fullName: user.social_name,
                    userName: user.user_name,
                    isVerified: user.is_verified,
                    followersCount: user.followers.where.not(id: user.blocked_users.pluck(:blocked_user)).count,
                    likesCount: user.reels.where(isReported: false, is_approved: true).sum(:like_count),
                  }
                end
                keyword_searched_reels.each do |reel|
                  creator = User.find(reel.creater_id)
                  reelList << {
                    reelId: reel.id,
                    videoUrl: reel.videoUrl,
                    likesCount: reel.like_count,
                    creatorId: creator.id,
                    creatorImageUrl: creator.social_img_url,
                    userName: creator.user_name,
                    isVerified: creator.is_verified,
                    bio: "#{creator.bio}",
                  }
                end
                data[:userList] = userList || []
                data[:reelList] = reelList || []
              end
              { status: 200, message: "Success", data: data }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - search - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end
    end
  end
end
