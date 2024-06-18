module API
  class Base < Grape::API
    mount API::V1::Auth
    mount API::V1::AppOpen
    mount API::V1::Reels
    mount API::V1::Home
    mount API::V1::Profile
    mount API::V1::Explore
    mount API::V1::Musics
    mount API::V1::Follows
  end
end
