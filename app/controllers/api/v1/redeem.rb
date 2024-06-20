module API
  module V1
    class Redeem < Grape::API
      include API::V1::Defaults

      resource :coinWallet do
        before {api_params}

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              wallet = {
                totalCoins: user.wallet_balance.to_s,
                conversion: "100 Coins = 1 USD",
                totalEarning: "0",
                totalspending: "0",
                purchased: "0",
                dailyCheckIn: "0",
                videoUpload: "0",
                fromYourFans: "0",
                dailyCheckInCoins: "5",
                uploadVideoCoins:"5",
                shoppingCoins: [
                  {coin: "5000",
                  rupees: "50"
                  },
                  {coin: "10000",
                  rupees: "100"
                  },
                  {coin: "20000",
                  rupees: "200"
                  },
                ]
              }
              { status: 200, message: "Success", wallet: wallet || {} }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - coinWallet - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :addCash do
        before {api_params}

        params do
          use :common_params
          requires :amount, type: String, allow_blank: false
          requires :paymentId, type: String, allow_blank: false
          requires :orderId, type: String, allow_blank: false
          requires :receipt, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              user.orders.create(amount: params[:amount], payment_id: params[:paymentId], order_id: params[:orderId],receipt: params[:receipt])
              wallet_balance = user.wallet_balance + (params[:amount].to_i * 100)
              user.update(wallet_balance: wallet_balance)
              user.notifications.create(content: "Purchased #{params[:amount]} Rupees Coins, #{params[:amount].to_i * 100} Coins Added",notification_type: "Coin Purchased")
              { status: 200, message: "Success", data: "Payment Successfull" }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - addCash - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end

      # resource :redeemList do
      #   before {api_params}

      #   params do
      #     use :common_params
      #   end

      #   post do
      #     begin
      #       user = User.find(params[:userId])
      #       if user.present?
      #         data = {}
      #         data[:totalCoins] = user.wallet_balance
      #         data[:conversion] = "100 Coin = 1 INR"
      #         payout_list = [
      #           {
      #             payoutId: 1,
      #             payoutName: "payout.name",
      #             payoutImageUrl: "payout.image_url",
      #             payoutAmounts: [10,20,30]
      #           },
      #           {
      #             payoutId: 1,
      #             payoutName: "payout.name",
      #             payoutImageUrl: "payout.image_url",
      #             payoutAmounts: [10,20,30]
      #           },
      #           {
      #             payoutId: 1,
      #             payoutName: "payout.name",
      #             payoutImageUrl: "payout.image_url",
      #             payoutAmounts: [10,20,30]
      #           }
      #         ]
      #         # Payout.all.each do |payout|
      #           # payout_list <<
      #         # end
      #         data[:payoutList] = payout_list
      #         { status: 200, message: "Success", data: data }
      #       else
      #         { status: 500, message: "User Not Found" }
      #       end
      #     rescue Exception => e
      #       Rails.logger.error "API Exception - #{Time.now} - redeemList - #{params.inspect} - Error - #{e.message}"
      #       { status: 500, message: "Error", error: e.message }
      #     end
      #   end
      # end



    end
  end
end
