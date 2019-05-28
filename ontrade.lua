function OnTrade(trade)
	sleep(2000)
	message(tostring(assets_limits[trade.sec_code]))
	if assets_limits[trade.sec_code] ~= 0 then
		signal = read_from_file(data_path..'/'..trade.sec_code..'/signal.csv')
		price_step = PRICE_STEP(trade.sec_code)
		dist_to_stop = tonumber(signal[1][3]) - math.fmod(tonumber(signal[1][3]), price_step)
		dist_to_profit = tonumber(signal[1][2]) - math.fmod(tonumber(signal[1][2]), price_step)
		if bit.band(trade.flags,4)>1 then
			sendTransaction(
				stop_trans(
					'B', trade.price - dist_to_stop, 
					trade.qty, trade.price - dist_to_stop, 
					trade.price + dist_to_profit, 
					trade.sec_code, price_step
				)
			)
			--message('Sell')
		elseif bit.band(trade.flags,4)==0 then
			sendTransaction(
				stop_trans(
					'S', trade.price + dist_to_stop, 
					trade.qty, trade.price + dist_to_stop, 
					trade.price - dist_to_profit, 
					trade.sec_code, price_step
				)
			)
			--message('Buy')
		end
	end
end