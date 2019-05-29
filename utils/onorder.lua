function OnOrder(order)
	if (quantity_in_stop(order.sec_code)==0 or quantity_in_stop(order.sec_code)==nil) then
		if bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 then
			signal = read_from_file(data_path..'/'..order.sec_code..'/signal.csv')
			price_step = PRICE_STEP(order.sec_code)
			dist_to_stop = tonumber(signal[1][3]) - math.fmod(tonumber(signal[1][3]), price_step)
			dist_to_profit = tonumber(signal[1][2]) - math.fmod(tonumber(signal[1][2]), price_step)
			if bit.band(order.flags,4)>1 then
				sendTransaction(
					stop_trans(
						'B', order.price - dist_to_stop, 
						order.qty, order.price - dist_to_stop, 
						order.price + dist_to_profit, 
						order.sec_code, price_step
					)
				)
				--message('Sell')
			elseif bit.band(order.flags,4)==0 then
				sendTransaction(
					stop_trans(
						'S', order.price + dist_to_stop, 
						order.qty, order.price + dist_to_stop, 
						order.price - dist_to_profit, 
						order.sec_code, price_step
					)
				)
				--message('Buy')
			end
		end
	end
end