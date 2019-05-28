require 'utils/string_split'
require 'utils/read_from_file'
require 'utils/quantity_in_stop'
require 'utils/id_of_stop_to_kill'
require 'utils/killstop_trans'
require 'utils/stop_trans'
require 'utils/getLotSizeBySecCode'
require 'utils/PRICE_STEP'
require 'utils/depo_limits'
--[[
function OnTrade(trade)
	sleep(2000)
	message(tostring(assets_limits[trade.sec_code]))
	
end
]]
data_path = 'C:/Users/Quotermain233/Desktop/VBShared/test/'

assets = {
		--"MGNT",
		--"TATN",
		--"SBERP",
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


assets_limits = {}

function run(asset)


	
	--message(tostring(quantity_in_stop(asset)))
--[[		
	
	--os.remove(data_path..'/ALRS/signal.csv')
		
	
		
	stakan=getQuoteLevel2("TQBR",asset)
	if stakan~=nil then
		price_to_buy=stakan.offer[1].price
		price_to_sell=stakan.bid[10].price
	end

	message(tostring(tonumber(signal[1][3])))
]]
	
	signal = read_from_file(data_path..'/'..asset..'/signal.csv')
	
	Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	lots_for_trade = math.ceil(Money * 0.001 / (tonumber(signal[1][3]) * lot_size))
	
	limits, price = depo_limits(asset)

	if limits ~= 0 and (quantity_in_stop(asset) == 0 or quantity_in_stop(asset) == nil) then
		dist_to_stop = tonumber(signal[1][3]) - math.fmod(tonumber(signal[1][3]), price_step)
		dist_to_profit = tonumber(signal[1][2]) - math.fmod(tonumber(signal[1][2]), price_step)
		if limits < 0 then
			sendTransaction(
				stop_trans(
					'B', price + dist_to_stop, 
					math.abs(limits) / lot_size, 
					price + dist_to_stop, 
					price - dist_to_profit, 
					asset, price_step
				)
			)
		elseif limits > 0 then
			sendTransaction(
				stop_trans(
					'S', price - dist_to_stop, 
					math.abs(limits) / lot_size, 
					price - dist_to_stop, 
					price + dist_to_profit, 
					asset, price_step
				)
			)
		end
	end
	--message(tostring(quantity_in_stop(asset)))
	sleep(100)
end

function main()	
    while true do
		for i=1, #assets do
			run(assets[i])
		end
	end
end






