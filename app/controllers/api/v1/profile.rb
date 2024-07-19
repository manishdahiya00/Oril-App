module API
  module V1
    class Profile < Grape::API
      include API::V1::Defaults

      resource :showProfile do
        before { api_params }

        params do
          use :common_params
          requires :page, type: String, allow_blank: false
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            require "will_paginate"
            user = User.find(params[:creatorId])
            if user.present?
              current_user = User.find(params[:userId])
              isFollowing = Follow.find_by(follower_id: current_user.id, following_id: user.id).present?
              isBlocked = current_user.blocked_users.find_by(blocked_user: params[:creatorId]).present?
              followers = user.followers.where.not(id: user.blocked_users.pluck(:blocked_user))
              following = user.following.where.not(id: user.blocked_users.pluck(:blocked_user))
              creatorReels = []
              likedReels = []
              profileData = {
                fullName: user.social_name,
                userImageUrl: user.social_img_url,
                userName: user.user_name,
                faceBookUrl: user.facebook_url,
                instaUrl: user.insta_url,
                youTubeUrl: user.yt_url,
                likesCount: user.reels.sum(:like_count),
                followersCount: followers.count,
                followingCount: following.count,
                userCategory: user.category || "Actor",
                userBio: user.bio,
                isVerified: user.is_verified,
              }
              if !isBlocked
                reels = user.reels.where(isReported: false, is_approved: true).paginate(page: params[:page], per_page: 12)
                reels.order(created_at: :desc).each_with_index do |reel, index|
                  creatorReels << {
                    reelId: reel.id,
                    reelUrl: reel.videoUrl,
                    views: reel.view_count,
                    index: index,
                    page: params[:page],
                  }
                end
                liked_reels = Like.where(user_id: user.id).joins(:reel)
                  .where(reels: { isReported: false, is_approved: true }).paginate(page: params[:page], per_page: 12)
                liked_reels.order(created_at: :desc).each_with_index do |reel, index|
                  liked_reel = Reel.find(reel.reel_id)
                  likedReels << {
                    reelId: liked_reel.id,
                    reelUrl: liked_reel.videoUrl,
                    views: liked_reel.view_count,
                    index: index,
                    page: params[:page],
                  }
                end
              end
              if user.id == current_user.id
                creatorLikedReels = likedReels
              else
                if user.show_liked_reels == true
                  creatorLikedReels = likedReels
                else
                  creatorLikedReels = []
                end
              end
              { status: 200, message: "Success", isFollowing: isFollowing, isBlocked: isBlocked, profileData: profileData || {}, creatorReels: creatorReels || [], creatorLikedReels: creatorLikedReels || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - showProfile - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :editProfile do
        before { api_params }

        params do
          use :common_params
          optional :profileCategory, type: String, allow_blank: true
          optional :profileImage, type: File, allow_blank: true
          optional :fullName, type: String, allow_blank: true
          optional :userName, type: String, allow_blank: true
          optional :bio, type: String, allow_blank: true
          optional :instagramUrl, type: String, allow_blank: true
          optional :fbUrl, type: String, allow_blank: true
          optional :youtubeUrl, type: String, allow_blank: true
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              if params[:profileImage].nil?
                image_url = user.social_img_url
              else
                image = ActionDispatch::Http::UploadedFile.new(params[:profileImage])
                image_url = user.profileImage.url
              end
              if params[:fullName].nil?
                social_name = user.social_name
              else
                social_name = params[:fullName]
              end
              user.update(social_img_url: image_url, category: params[:profileCategory], social_name: social_name, user_name: params[:userName], bio: params[:bio], insta_url: params[:instagramUrl], yt_url: params[:youtubeUrl], facebook_url: params[:fbUrl], profileImage: image)
              { status: 200, message: "Success", data: "Profile updated successfully" }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - editProfile - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :likesList do
        before { api_params }

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              data = []
              creator = User.find(params[:creatorId])
              user_reels_ids = creator.reels.where(isReported: false, is_approved: true).pluck(:id)
              user_liked_reels = Like.where(reel_id: user_reels_ids)
              user_ids_who_liked = user_liked_reels.pluck(:user_id)
              users = User.where(id: user_ids_who_liked).where.not(id: user.blocked_users.pluck(:blocked_user))
              users.each do |user|
                user.likes.where(reel_id: user_reels_ids).each do |like|
                  data << {
                    reelId: like.reel_id,
                    creatorId: user.id,
                    creatorImageUrl: user.social_img_url,
                    fullName: user.social_name,
                    userName: user.user_name,
                    isVerified: user.is_verified,
                    followersCount: user.followers.count,
                    likesCount: user.reels.sum(:like_count),
                  }
                end
              end
              { status: 200, message: "Success", data: data || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - likesList - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :followersList do
        before { api_params }

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              creator = User.find(params[:creatorId])
              data = []
              creator.followers.where.not(id: user.blocked_users.pluck(:blocked_user)).each do |user|
                data << {
                  creatorId: user.id,
                  creatorImageUrl: user.social_img_url,
                  fullName: user.social_name,
                  userName: user.user_name,
                  isVerified: user.is_verified,
                  followersCount: user.followers.count,
                  likesCount: user.reels.sum(:like_count),
                }
              end
              { status: 200, message: "Success", data: data || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - followersList - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :followingsList do
        before { api_params }

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              creator = User.find(params[:creatorId])
              data = []
              creator.following.where.not(id: user.blocked_users.pluck(:blocked_user)).each do |user|
                data << {
                  creatorId: user.id,
                  creatorImageUrl: user.social_img_url,
                  fullName: user.social_name,
                  userName: user.user_name,
                  isVerified: user.is_verified,
                  followersCount: user.followers.count,
                  likesCount: user.reels.sum(:like_count),
                }
              end
              { status: 200, message: "Success", data: data || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - followersList - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :blockCreator do
        before { api_params }

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              creator = User.find(params[:creatorId])
              if creator.id != user.id
                if creator.present?
                  blocked_user = user.blocked_users.find_by(blocked_user: params[:creatorId])
                  { status: 200, message: "Success", data: "Creator removed from blocklist" }
                  if !blocked_user.present?
                    user.blocked_users.create(blocked_user: params[:creatorId].to_i)
                    { status: 200, message: "Success", data: "You blocked this creator" }
                  else
                    blocked_user.destroy
                    { status: 200, message: "Success", data: "You unblocked this creator" }
                  end
                else
                  { status: 500, message: "Creator Not Found" }
                end
              end
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - blockCreator - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :settingList do
        before { api_params }

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              if user.show_liked_reels == true
                showReels = true
              else
                showReels = false
              end
              data = {
                showYourLikedVideos: showReels,
                shareProfile: "Hi, I am using this Amazing & Wonderful App to get rid of my Boredom in the Leisure Time. Download & Try this App. Click here: #{BASE_URL}/invite/#{user.refer_code}/",
                verification: user.status,
                termsOfUse: "#{BASE_URL}/terms_of_use.html",
                privacyPolicy: "#{BASE_URL}/privacy_policy.html",
              }
              { status: 200, message: "Success", data: data }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - settingList - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :blockedProfile do
        before { api_params }

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              blockedUsers = []
              user.blocked_users.each do |user|
                blockedUser = User.find(user.blocked_user)
                blockedUsers << {
                  creatorId: blockedUser.id,
                  fullName: blockedUser.social_name,
                  userName: blockedUser.social_name,
                  creatorImageUrl: blockedUser.social_img_url,
                  isVerified: blockedUser.is_verified,
                }
              end
              { status: 200, message: "Success", blockedUsers: blockedUsers || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - blockedProfile - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :verificationRequest do
        before { api_params }

        params do
          use :common_params
          requires :socialType, type: String, allow_blank: false
          requires :socialId, type: String, allow_blank: false
          requires :image, type: File, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              image = ActionDispatch::Http::UploadedFile.new(params[:image])
              VerificationRequest.create(
                user_id: user.id,
                social_type: params[:socialType],
                social_id: params[:socialId],
                selfie_image: image,
              )
              user.update(status: "Verification Pending")
              { status: 200, message: "Success", data: "Verification Request Submitted" }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - blockedProfile - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end

      resource :updateSetting do
        before { api_params }

        params do
          use :common_params
          optional :showYourLikedVideos, type: String, allow_blank: true
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              user.update(show_liked_reels: params[:showYourLikedVideos])
              { status: 200, message: "Success", data: "Settings updated successfully" }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - updateSettings - #{params.inspect} - Error - #{e}"
            { status: 500, message: "Error", error: e }
          end
        end
      end
    end
  end
end
