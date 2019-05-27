require 'utils/string_split'
require 'utils/read_from_file'
require 'utils/quantity_in_stop'
require 'utils/id_of_stop_to_kill'
require 'utils/killstop_trans'
require 'utils/stop_trans'
require 'utils/getLotSizeBySecCode'
require 'utils/PRICE_STEP'

function quantity_in_stop(seccode)
	local t=nil
	local stop_number=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==seccode and bit.band(t.flags,1)>0 then
			stop_number=t.qty
		end
	end
	return stop_number
end

--Надо одну стоп заявку. Посылает две.
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
						order.price + dist_to_profit, 
						order.sec_code, price_step
					)
				)
				--message('Buy')
			end
		end
	end
end

data_path = 'C:/Users/Quotermain233/Desktop/VBShared/test/'

assets = {
		"MGNT",
		"TATN",
		"SBERP",
		--"MTLR",
		"ALRS",
		"SBER",
		"MOEX",
		"HYDR",
		"ROSN",
		"LKOH",
		"SIBN",
		"GMKN",
		"RTKM",
		"SNGS",
		"SNGSP",
		"CHMF",
		--"VTBR",
		"NVTK",
		"GAZP",
		--"MSNG",
		"MTSS",
		"YNDX"
}

function run(asset)


	
	--message(tostring(quantity_in_stop(asset)))
--[[		
	signal = read_from_file(data_path..'/'..asset..'/signal.csv')
	--os.remove(data_path..'/ALRS/signal.csv')
		
	Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	lots_for_trade = math.ceil(Money * 0.001 / (tonumber(signal[1][3]) * lot_size))
	dist_to_stop = tonumber(signal[1][3]) - math.fmod(tonumber(signal[1][3]), price_step)
		
	stakan=getQuoteLevel2("TQBR",asset)
	if stakan~=nil then
		price_to_buy=stakan.offer[1].price
		price_to_sell=stakan.bid[10].price
	end

	message(tostring(tonumber(signal[1][3])))
]]		
	sleep(3000)
end

function main()	
    while true do
		for i=1, #assets do
			run(assets[i])
		end
	end
end