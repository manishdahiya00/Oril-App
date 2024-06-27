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
                conversion: "100 Coins = 1 INR",
                totalEarning: user.wallet_balance.to_s,
                totalspending: user.total_spending.to_s,
                purchased: user.orders.sum(:amount).to_i * 100,
                dailyCheckIn: user.check_in_balance.to_s,
                videoUpload: user.video_upload_coins.to_s,
                fromYourFans: user.received_from_fans.to_s,
                dailyCheckInCoins: "5",
                uploadVideoCoins:"10",
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
              user.transactions.create(transaction_name: "Added Coins",transaction_amount: params[:amount],transaction_coins: params[:amount].to_i * 100)
              user.notifications.create(content: "Purchased #{params[:amount]} Rupees Coins, #{params[:amount].to_i * 100} Coins Added",notification_type: "transaction")
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

      resource :redeemList do
        before {api_params}

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              data = {}
              data[:totalCoins] = user.wallet_balance
              data[:conversion] = "100 Coin = 1 USD"
              payout_list = []
              Payout.all.each do |payout|
                payout_list << {
                  payoutId: payout.id,
                  payoutName: payout.payout_name,
                  payoutImageUrl: payout.payout_img_url,
                  payoutAmounts: payout.payout_amount.split(',')
                }
              end
              data[:payoutList] = payout_list
              { status: 200, message: "Success", data: data }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - redeemList - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :redeemSubmit do
        before {api_params}

        params do
          use :common_params
          requires :numberOrEmail, type: String, allow_blank: false
          requires :upiId, type: String, allow_blank: false
          requires :coins, type: String, allow_blank: false
          requires :payoutId, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
             if user.wallet_balance >= params[:coins].to_i
              user.redeems.create(number_or_email: params[:numberOrEmail], upi_id: params[:upiId], coins: params[:coins], payout_id: params[:payoutId],status: "PENDING")
              wallet_balance = user.wallet_balance - params[:coins].to_i
              user.update(wallet_balance: wallet_balance)
              user.transactions.create(transaction_name: "Withdrawl Request",transaction_amount: params[:coins].to_f / 100,transaction_coins: params[:coins])
              Notification.create(creator_id: user.id,content: "Withdrawl request for #{params[:coins]} coins submitted successfully. Approved Soon",notification_type: "transaction")
              { status: 200, message: "Success", data: "Request Submitted, Approved Soon." }
             else
              { status: 500, message: "Not Enough Balance" }
             end
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - redeemSubmit - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :sendGift do
        before {api_params}

        params do
          use :common_params
          requires :creatorId, type: String, allow_blank: false
          requires :coins, type: String, allow_blank: false
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              creator = User.find(params[:creatorId])
              if user.wallet_balance.to_i >= params[:coins].to_i
                user_balance = user.wallet_balance - params[:coins].to_i
                creator_balance = creator.wallet_balance + params[:coins].to_i
                received_from_fans = creator.received_from_fans + params[:coins].to_i
                user.update(wallet_balance: user_balance,total_spending: params[:coins].to_i)
                creator.update(wallet_balance: creator_balance,received_from_fans: received_from_fans)
                user.transactions.create(transaction_name: "Sent Gift",transaction_amount: params[:coins].to_f / 100,transaction_coins: params[:coins])
                Notification.create(user_id: creator.id,content: "#{user.user_name} gifted you #{params[:coins]} coins",notification_type: "gift",creator_id: user.id)
                { status: 200, message: "Success", data: "Gift sent successfully" }
              else
                { status: 500, message: "Not enough balance" }
              end
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - sendGift - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end


      resource :transactionHistory do
        before {api_params}

        params do
          use :common_params
        end

        post do
          begin
            user = User.find(params[:userId])
            if user.present?
              transactions = []
              user.transactions.all.each do |transaction|
                transactions << {
                  title: transaction.transaction_name,
                  subtitle: transaction.created_at.strftime("%d/%m/%y %I:%M %p"),
                  coins: transaction.transaction_coins
                }
              end
              { status: 200, message: "Success", data: transactions || [] }
            else
              { status: 500, message: "User Not Found" }
            end
          rescue Exception => e
            Rails.logger.error "API Exception - #{Time.now} - transactionHistory - #{params.inspect} - Error - #{e.message}"
            { status: 500, message: "Error", error: e.message }
          end
        end
      end





    end
  end
end
