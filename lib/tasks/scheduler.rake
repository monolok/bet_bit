
# desc "testing"
# task :bet => :environment do
# 	x = BlockIo.get_network_fee_estimate :amounts => '1', :to_addresses => '2N5EAyoqWsQQVywzWebinoNqRtywTzceJCM'
# 	puts "testing done: #{x}"
# end


# MINIMUM BET 0.01 BTC
# Btc network fee is 0.11% apx. with min 0.001 (occur 2 times max)
# Bet_bit fee is 5% of winning funds
# Payout takes 2 hours


desc "New/close/clean bets (cron task)"
task :bet => :environment do
	
	#creating current bet at :00
	puts "creating current bet..."
	@kraken_btc_eur = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)	
	@bet = Bet.new
	@bet.base_price = @kraken_btc_eur
	@bet.status = "Active"
	@bet.save
	puts "current bet #{@bet.id} created."

	#Action on the previous bet: update client status(paid or not) and close the bet with its result
	puts "Updating client status and closing bet..."
	if Bet.all.count >= 3
		@bet_to_update_clients_id = (Bet.last.id) - 1
		@bet_to_update_clients = Bet.find(@bet_to_update_clients_id)
		@bet_to_close_id = (Bet.last.id) - 2
		@bet_to_close = Bet.find(@bet_to_close_id)		
		#check for clients payments and update their status accordingly
		i = 0
		while i < @bet_to_update_clients.gamblers.count do
			balance = BlockIo.get_address_balance :addresses => @bet_to_update_clients.gamblers[i].bet_address
			if balance["data"]["available_balance"].to_f > 0 || balance["data"]["pending_received_balance"].to_f > 0
				@bet_to_update_clients.gamblers[i].update(status: true)
				puts "Client #{@bet_to_update_clients.gamblers[i].id} status updated"
			end
			i+=1
		end
		puts "clients status updated from bet #{@bet_to_update_clients.id}."
		#closing bet with its result and updated status	
		if @kraken_btc_eur > @bet_to_update_clients.base_price 
			@bet_to_update_clients.update(last_price: @kraken_btc_eur, status: "Closed", result: "up")
		elsif @kraken_btc_eur < @bet_to_update_clients.base_price
			@bet_to_update_clients.update(last_price: @kraken_btc_eur, status: "Closed", result: "down")
		else
			@bet_to_update_clients.update(last_price: @kraken_btc_eur, status: "Closed", result: "same")
		end
		puts "bet #{@bet_to_update_clients.id} is #{@bet_to_update_clients.status} with result #{@bet_to_update_clients.result}"
	else
		puts "no bet with clients to update or bet to close."
	end
		
	#determine winners and money to payout from the loosers
	if Bet.exists?(@bet_to_close_id) == true && @bet_to_close.gamblers.any? == true
		#set winners to 0 if bet result is "same"
		if Bet.find(@bet_to_close_id).result == "same"
			@winners = []
			@loosers = []
			puts "not loosers and no winners"
		else
			@winners = @bet_to_close.gamblers.where("#{@bet_to_close.result}": true, status: true)
			@loosers = @bet_to_close.gamblers.where("#{@bet_to_close.result}": false, status: true)
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
				won_less_fee = won - (won * 0.05).to_f
				winner_bet_hash = BlockIo.get_address_balance :addresses => @winners[z].bet_address
				winner_bet = winner_bet_hash["data"]["available_balance"].to_f
				puts "paying #{won_less_fee} + #{winner_bet} to #{@winners[z].client_address}"
				puts "Bet_bit made #{(won * 0.005).to_f} BTC"
				BlockIo.withdraw :amounts => "#{won_less_fee}, #{winner_bet}", :to_addresses => "#{@winners[z].client_address}"
				z+=1
			end
		end
	end

	#cleaning the history table
	puts "cleaning bet history table..."
	if Bet.all.count > 6
		@bet_to_destroy = Bet.first		
		#Destory btc addresses associated with the bet_to_destroy
		if @bet_to_destroy.gamblers.count > 0
			u = 0
			while u > @bet_to_destroy.gamblers.count
				balance_hash = BlockIo.get_address_balance :addresses => @bet_to_destroy.gamblers[u].bet_address
				balance = balance_hash["data"]["available_balance"].to_f
				if not balance > 0
					BlockIo.archive_addresses :addresses => @bet_to_destroy.gamblers[u].bet_address
					puts "BTC address: #{@bet_to_destroy.gamblers[u].bet_address} archived"					
				end
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