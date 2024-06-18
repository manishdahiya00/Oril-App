module API
  module V1
    class Musics < Grape::API
      include API::V1::Defaults


      resource :musicDetail do
        before {api_params}

        params do
          use :common_params
          requires :musicId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              ActiveStorage::Current.url_options = { host:"http://192.168.1.32:8000" }
              reels = []
              music = Music.find(params[:musicId])
              isFavourite = user.fav_musics.find_by(music_id: params[:musicId]).present?
              musicDetails = {
                  musicTitle: music.title,
                  musicUrl: music.music_url,
                  reelsCount: music.reels.count,
                  isFavourite: isFavourite
                }
                music.reels.where(isReported: false).each do |reel|
                  reels << {
                      reelId: reel.id,
                      reelUrl: reel.video.url,
                      viewCount: reel.view_count
                }
                end
              { status: 200, message: "Success", musicDetail: musicDetails || {}, reel: reels || []}
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - musicDetail - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :musicList do
        before {api_params}

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              discover = []
              favourite = []
              Music.all.each do |music|
                isFavourite = user.fav_musics.find_by(music_id: music.id).present?
                discover << {
                  musicId: music.id,
                  musicTitle: music.title,
                  musicSinger: music.singer,
                  musicUrl: music.music_url,
                  musicImage: music.image_url,
                  isFavourite: isFavourite
                }
              end
              user.fav_musics.each do |fav_music|
                music = Music.find(fav_music.music_id)
                favourite << {
                  musicId: music.id,
                  musicTitle: music.title,
                  musicSinger: music.singer,
                  musicUrl: music.music_url,
                  musicImage: music.image_url,
                  isFavourite: true
                }
              end
              { status: 200, message: "Success", discover: discover || [], favourite: favourite || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - musicList - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :favouriteMusic do
        before {api_params}

        params do
          use :common_params
          requires :musicId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              music = Music.find(params[:musicId])
              if music.present?
                if user.fav_musics.find_by(music_id: params[:musicId]).present?
                  user.fav_musics.find_by(music_id: params[:musicId]).destroy
                 { status: 200, message: "Success", data: "Music removed from favorites"}
                else
                  user.fav_musics.create(music_id: params[:musicId])
                 { status: 200, message: "Success", data: "Music added to favorites"}
                end
              else
              { status: 500, message: "Music Not Found" }
              end
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - favouriteMusic - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end



    end
  end
end
