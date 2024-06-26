module API
  module V1
    class Reels < Grape::API
      include API::V1::Defaults

     resource :videoUpload do
      before {api_params}


      params do
        use :common_params
        optional :allow_comments,type: String, allow_blank: true
        optional :description,type: String, allow_blank: true
        optional :hashtags,type: String, allow_blank: true
        optional :musicId,type: String, allow_blank: true
        requires :video,type: File, allow_blank: false

      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            video = ActionDispatch::Http::UploadedFile.new(params[:video])
            reel = user.reels.create(
              music_id: params[:musicId] || nil,
              allow_comments: params[:allowComments],
              hastags: params[:hashtags],
              description: params[:description],
              video: video
            )
            video_url = reel.video.url.sub(/\?.*/, '')
            reel.update(videoUrl: video_url)
            { status: 200, message: "Success", data: "Reel Created Successfully" }
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - videoUpload - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
     end



     resource :likeReel do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
           if user.likes.find_by(reel_id: params[:reelId]).present?
            user.likes.find_by(reel_id: params[:reelId]).destroy
            likeCount = reel.like_count - 1
            reel.update(like_count: likeCount)
            { status: 200, message: "Success", data: "Reel unliked Successfully" }
           else
            user.likes.create(reel_id: params[:reelId])
            Notification.create(user_id: reel.creater_id,creator_id: params[:userId],content: "#{user.user_name} liked your reel",notification_type: "like",reel_id: reel.id)
            likeCount = reel.like_count + 1
            reel.update(like_count: likeCount)
            { status: 200, message: "Success", data: "Reel Liked Successfully" }
           end
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - likeReel - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end



    resource :reelsList do
      before {api_params}

      params do
         use :common_params
         optional :musicId, type: String, allow_blank: true
         optional :reelId, type: String, allow_blank: true
         optional :creatorReels, type: String, allow_blank: true
         optional :hashtag, type: String, allow_blank: true
         optional :creatorLikedReels, type: String, allow_blank: true
         optional :category, type: String, allow_blank: true
         optional :page, type: String, allow_blank: true
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reels = []
            if params[:reelId].present?
              reel = Reel.find(params[:reelId])
              creator = User.find(reel.creater_id)
              isLiked = user.likes.find_by(reel_id: reel.id).present?
              reels << {
                reelId: reel.id,
                allowComments: reel.allow_comments,
                videoUrl: reel.video.url,
                isLiked: isLiked,
                reelDescription: reel.description,
                musicTitle: reel.music&.title,
                musicId: reel.music&.id,
                likes: reel.like_count,
                comments: reel.comments.count,
                creatorId: creator.id,
                creatorName: creator.social_name,
                creatorImageUrl: creator.social_img_url,
                isVerified: creator.is_verified,
                profileCategory: creator.category,
                shareUrl:  "Hi, I am using this Amazing & Wonderful App to get rid of my Boredom in the Leisure Time. Download & Try this App. Click here: #{BASE_URL}/reels/#{reel.id}/?inviteBy=#{creator.refer_code}",
              }
            elsif params[:musicId].present?
              music = Music.find(params[:musicId])
              music.reels.where(isReported: false,is_approved: true).order(created_at: :desc).each do |reel|
              creator = User.find(reel.creater_id)
              isLiked = user.likes.find_by(reel_id: reel.id).present?
                reels << {
                  reelId: reel.id,
                  allowComments: reel.allow_comments,
                  videoUrl: reel.video.url,
                  isLiked: isLiked,
                  reelDescription: reel.description,
                  musicTitle: reel.music&.title,
                  musicId: reel.music&.id,
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
            elsif params[:hashtag].present?
              normalized_hashtag = params[:hashtag].gsub("#", "")
              hashtags = Reel.where("hastags LIKE ?", "%#{normalized_hashtag}%")
              hashtags.where(isReported: false, is_approved: true).each do |reel|
                creator = User.find(reel.creater_id)
                isLiked = user.likes.find_by(reel_id: reel.id).present?
                reels << {
                  reelId: reel.id,
                  allowComments: reel.allow_comments,
                  videoUrl: reel.videoUrl,
                  isLiked: isLiked,
                  reelDescription: reel.description,
                  musicTitle: reel.music&.title,
                  musicId: reel.music&.id,
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
            elsif  params[:creatorReels].present?
              creator = User.find(params[:creatorReels])
              user_reels = creator.reels.where(isReported: false,is_approved: true).order(created_at: :desc).where.not(creater_id: user.blocked_users.pluck(:blocked_user)).paginate(page: params[:page],per_page: 12)
              user_reels.each do |reel|
                isLiked = user.likes.find_by(reel_id: reel.id).present?
                reels << {
                  reelId: reel.id,
                  allowComments: reel.allow_comments,
                  videoUrl: reel.video.url,
                  isLiked: isLiked,
                  reelDescription: reel.description,
                  musicTitle: reel.music&.title,
                  musicId: reel.music&.id,
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
            elsif  params[:creatorLikedReels].present?
              creator = User.find(params[:creatorLikedReels])
              user_likes = creator.likes.where.not(user_id: user.blocked_users.pluck(:blocked_user)).paginate(page: params[:page],per_page: 12).pluck(:reel_id)
              user_reels = Reel.where(id: user_likes,isReported: false,is_approved: true)
              user_reels.each do |reel|
                reel_creator = User.find(reel.creater_id)
                isLiked = creator.likes.find_by(reel_id: reel.id).present?
                reels << {
                  reelId: reel.id,
                  allowComments: reel.allow_comments,
                  videoUrl: reel.video.url,
                  isLiked: isLiked,
                  reelDescription: reel.description,
                  musicTitle: reel.music&.title,
                  musicId: reel.music&.id,
                  likes: reel.like_count,
                  comments: reel.comments.count,
                  creatorId: reel_creator.id,
                  creatorName: reel_creator.social_name,
                  creatorImageUrl: reel_creator.social_img_url,
                  isVerified: creator.is_verified,
                  profileCategory: reel_creator.category,
                  shareUrl:  "Hi, I am using this Amazing & Wonderful App to get rid of my Boredom in the Leisure Time. Download & Try this App. Click here: #{BASE_URL}/reels/#{reel.id}/?inviteBy=#{reel_creator.refer_code}",
              }
            end
            elsif  params[:category].present?
              user_reels = Reel.where(isReported: false,is_approved: true).where.not(creater_id: user.blocked_users.pluck(:blocked_user)).order(like_count: :desc).joins(:user).where(user: { category: params[:category] }).paginate(page: params[:page], per_page: 12)
              user_reels.each do |reel|
                creator = User.find(reel.creater_id)
                isLiked = user.likes.find_by(reel_id: reel.id).present?
                reels << {
                  reelId: reel.id,
                  allowComments: reel.allow_comments,
                  videoUrl: reel.video.url,
                  isLiked: isLiked,
                  reelDescription: reel.description,
                  musicTitle: reel.music&.title,
                  musicId: reel.music&.id,
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
            else
            user.reels.where(isReported: false,is_approved: true).order(created_at: :desc).paginate(page: params[:page], per_page: 12).each do |reel|
              creator = User.find(reel.creater_id)
              if reel.music_id.present?
                music = Music.find(reel.music_id)
              else
                music = nil
              end
              isLiked = user.likes.find_by(reel_id: reel.id).present?
              reels << {
                reelId: reel.id,
                allowComments: reel.allow_comments,
                videoUrl: reel.video.url,
                isLiked: isLiked,
                reelDescription: reel.description,
                musicTitle: music&.title,
                musicId: music&.id,
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
          Rails.logger.error "API Exception - #{Time.now} - reelsList - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end



    resource :addComment do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
         requires :content, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
            reel.comments.create(content: params[:content],user_id: params[:userId])
            Notification.create(user_id: reel.creater_id,creator_id: params[:userId],content: "#{user.user_name} commented on your reel",notification_type: "comment",reel_id: reel.id)
            { status: 200, message: "Success", data: "Comment Added Successfully" }
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - addComment - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end

    resource :commentList do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
            data = []
            reel.comments.order(created_at: :desc).each do |comment|
              user = User.find(comment.user_id)
              data << {
                commentId: comment.id,
                commentContent: comment.content,
                creatorImageUrl: user.social_img_url,
                creatorName: user.social_name,
                creatorIsVerified: user.is_verified,
                creatorId: user.id,
              }
            end
            { status: 200, message: "Success", data: data || [] }
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - commentList - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end


    resource :commentDelete do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
         requires :commentId, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
              comment = Comment.find(params[:commentId])
              if comment.present?
                reel.comments.find(params[:commentId]).destroy
            { status: 200, message: "Success", data: "Comment Deleted Successfully" }
              else
            { status: 500, message: "Comment Not Found" }
              end
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - commetDelete - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end


    resource :viewCount do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
              if params[:userId].to_s == reel.creater_id.to_s
                { status: 200, message: "Success", data: true }
              else
                view_count = reel.view_count + 1
                reel.update(view_count: view_count)
                { status: 200, message: "Success", data: true }
              end
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - viewCount - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end


    resource :deleteReel do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = user.reels.find(params[:reelId])
            if reel.present?
              puts reel.comments
              if reel.comments.present?
                Comment.where(reel_id: params[:reelId]).destroy_all
              end
              liked_reel = Like.find_by(reel_id: reel.id)
              reel.destroy
              if liked_reel.present?
                liked_reel.destroy
              end
            { status: 200, message: "Success", data: "Reel deleted successfully" }
            else
            { status: 500, message: "Reel Not Found" }
            end
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - deleteReel - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end



    resource :reportReel do
      before {api_params}

      params do
         use :common_params
         requires :reelId, type: String, allow_blank: false
         requires :reason, type: String, allow_blank: false
         requires :briefMessage, type: String, allow_blank: false
      end
      post do
        begin
          user = User.find(params[:userId])
          if user.present?
            reel = Reel.find(params[:reelId])
            if reel.report_count == 0
              ReportedReel.create(user_id: params[:userId],reel_id: params[:reelId],reporting_reason: params[:reason],description: params[:briefMessage])
              reel.update(report_count: reel.report_count + 1,isReported: true)
            else
              reel.update(report_count: reel.report_count + 1)
            end
            { status: 200, message: "Success", data: "Reel reported successfully" }
          else
            { status: 500, message: "User Not Found" }
          end
        rescue Exception => e
          Rails.logger.error "API Exception - #{Time.now} - reportReel - #{params.inspect} - Error - #{e.message}"
          { status: 500, message: "Error", error: e.message }
        end
      end
    end



    end
  end
end
