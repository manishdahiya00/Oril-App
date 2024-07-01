module API
  module V1
    module Defaults
      extend Grape::API::Helpers

      BASE_URL = "https://www.orilshorts.app"
      COIN_LIST = ["20", "40", "60", "80", "100"]
      PROFILE_CATEGORY = ["Dance", "Politics", "Actor", "Sports", "Decor"]
      PROFILE_HASHTAGS = ["trending", "love", "motivation", "funny", "travel"]

      def self.included(base)
        base.prefix :api
        base.version :v1
        base.format :json

        base.helpers do
          params :common_params do
            requires :userId, type: String, allow_blank: false
            requires :securityToken, type: String, allow_blank: false
            requires :versionName, type: String, allow_blank: false
            requires :versionCode, type: String, allow_blank: false
          end

          def api_params
            Rails.logger.info "API Params:#{params.inspect}"
          end
        end
      end
    end
  end
end
