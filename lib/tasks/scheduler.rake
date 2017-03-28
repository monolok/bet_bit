
# desc "testing"
# task :bet => :environment do

# 	x = BlockIo.get_network_fee_estimate :amounts => '1', :to_addresses => '2N5EAyoqWsQQVywzWebinoNqRtywTzceJCM'

# 	puts "testing done: #{x}"
# end



####################SET MINIMUM BET to 0.01 BTC, network fee + comm
##### SET FREQUENCY OF BET TO UPDATE CLIENT STATUS (PAID OR NO) AND BET TO CLOSE FOR PAY OUT


desc "New/close/clean bets (cron task)"
task :bet => :environment do
	
	#creating current bet
	puts "creating current bet..."
	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)	
	@bet = Bet.new
	@bet.base_price = @kraken_btc_eur
	@bet.status = "Active"
	@bet.save
	puts "current bet #{@bet.id} created."

	#update client status(paid or not, true/false)
	puts "Updating client status..."
	if Bet.all.count >= 4
		@bet_to_update_clients_id = (Bet.last.id) - 2
		@bet_to_update_clients = Bet.find(@bet_to_update_clients_id)
		#check for clients payments and update their status accordingly
		i = 0
		while i < @bet_to_update_clients.clients.count do
			balance = BlockIo.get_address_balance :addresses => @bet_to_update_clients.clients[i].bet_address
			if balance["data"]["available_balance"].to_f > 0 || balance["data"]["pending_received_balance"].to_f > 0
				@bet_to_update_clients.clients[i].update(status: true)
				puts "Client #{@bet_to_update_clients.clients[i].id} status updated"
			end
			i+=1
		end
		puts "clients status updated from bet #{@bet_to_update_clients.id}."
	else
		puts "no bet with clients to update."
	end
		
	#closing bet with its result and updated status
	puts "closing bet..."
	if Bet.all.count >= 4
		@bet_to_close_id = (Bet.last.id) - 3
		@bet_to_close = Bet.find(@bet_to_close_id)
		if @kraken_btc_eur > @bet_to_close.base_price 
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "up")
		elsif @kraken_btc_eur < @bet_to_close.base_price
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "down")
		else
			@bet_to_close.update(last_price: @kraken_btc_eur, status: "Closed", result: "same")
		end
		puts "bet #{@bet_to_close.id} is #{@bet_to_close.status} with result #{@bet_to_close.result}"
	else
		puts "no bet to close."
	end

	#determine winners and money to payout from the loosers
	if Bet.exists?(@bet_to_close_id) == true && @bet_to_close.clients.any? == true
		#set winners to 0 if bet result is "same"
		if Bet.find(@bet_to_close_id).result == "same"
			@winners = []
			@loosers = []
			puts "not loosers and no winners"
		else
			@winners = @bet_to_close.clients.where("#{@bet_to_close.result}": true, status: true)
			@loosers = @bet_to_close.clients.where("#{@bet_to_close.result}": false, status: true)
			puts "Tere are #{@winners.count} winners and #{@loosers.count} loosers"
		end

		if @loosers.count == 0 && @winners.count != 0
			puts "no loosers and some winners"
			i = 0
			#if no loosers and some winners refund each winner
			while i < @winners.count 
				balance_hash = BlockIo.get_address_balance :addresses => @winners[i].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				BlockIo.withdraw :amounts => "#{balance}", :to_addresses => "#{@winners[i].client_address}"
				i+=1
				puts "refunding #{balance} to client #{@winners[i].id}"
			end
		elsif @winners.count == 0
			#if no winners do nothing and keep the money
			puts "no winners"
		else
			#sum of bitcoins from all loosers
			i = 0
			@funds_loosers = Array.new
			while i < @loosers.count
				balance_hash = BlockIo.get_address_balance :addresses => @loosers[i].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				@funds_loosers << balance
				i+=1
			end
			@loosers_sum = @funds_loosers.inject(:+)
			puts "sum to payout is #{@loosers_sum}"

			#sum of winner btc to dermine % to distribute
			y = 0
			@funds_winners = Hash.new
			@win_sum = Array.new
			while y < @winners.count
				balance_hash = BlockIo.get_address_balance :addresses => @winners[y].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				@funds_winners["@winners[y].id"] = balance
				@win_sum << balance
				y+=1
			end
			@winners_sum = @win_sum.inject(:+)
			puts "sum of winners is #{@winners_sum}"
			puts "summary of winers: #{@funds_winners}"

			#pay out winners based on % of their bet
			z = 0
			while z < @winners.count
				won = (@funds_winners.key(@winners[z].id).to_f / @winners_sum) * @loosers_sum
				puts "paying #{won} to #{@winners[z].client_address}"
				BlockIo.withdraw :amounts => "#{won}", :to_addresses => "#{@winners[z].client_address}"
				z+=1
			end
		end
	end

	#cleaning the history table
	puts "cleaning bet history table..."
	if Bet.all.count > 6
		@bet_to_destroy = Bet.first		
		#Destory btc addresses associated with the bet_to_destroy
		if @bet_to_destroy.clients.count > 0
			u = 0
			while u > @bet_to_destroy.clients.count
				BlockIo.archive_addresses :addresses => "#{@bet_to_destroy.clients[u].bet_address}"
				puts "BTC address: #{@bet_to_destroy.clients[u].bet_address} archived"
				u+=1
			end
		end
  		#destroy the oldest bet along with its associated clients if any
  		puts "Destroying Bet #{@bet_to_destroy.id}"
  		@bet_to_destroy.destroy	
  		puts "Table cleaned and related btc address deleted"
  	else
  		puts "no bet deleted, there are less than 6 bets."
  	end
#end of task
end