class KrakenJob 
  include SuckerPunch::Job
  
  def perform
  	h = HTTParty.get("https://api.kraken.com/0/public/Ticker?pair=XXBTZEUR")["result"]["XXBTZEUR"]["c"][0].to_f.round(2)
  	puts h
  end
end
