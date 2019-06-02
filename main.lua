require 'utils/string_split'
require 'utils/read_from_file'
require 'utils/quantity_in_stop'
require 'utils/id_of_stop_to_kill'
require 'utils/killstop_trans'
require 'utils/stop_trans'
require 'utils/getLotSizeBySecCode'
require 'utils/PRICE_STEP'
require 'utils/depo_limits'
require 'utils/order_limits'
require 'utils/trans'
--[[
function OnTrade(trade)
	sleep(2000)
	message(tostring(assets_limits[trade.sec_code]))
	
end
]]
data_path = 'C:/Users/Quotermain233/Desktop/VBShared/test/'

assets = {
		"MGNT",
		"TATN",
		"SBERP",
		"MTLR",
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
	
	signal = read_from_file(data_path..'/'..asset..'/signal.csv')
	
	if signal and #signal ~= 0 and signal[1][1] and signal[1][2] and signal[1][3] then
	
		Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value
		
		lot_size = getLotSizeBySecCode(asset)
		
		price_step = PRICE_STEP(asset)
		
		dist_to_stop = tonumber(signal[1][3])
		lots_for_trade = math.floor(Money * 0.0001 / (dist_to_stop * lot_size))

		stakan=getQuoteLevel2("TQBR",asset)
		if stakan~=nil then
			price_to_buy=stakan.offer[1].price
			price_to_sell=stakan.bid[10].price
		end
		
		limits, price = depo_limits(asset)
		
		if (limits == 0 or limits == nil) 
		and (order_limits(asset) == 0 or order_limits(asset)) == nil then
			if signal[1][1] == 'short' then
				sendTransaction(
					trans(
						asset, 'S', 
						price_to_sell - 100 * price_step,
						lots_for_trade
					)
				)
			elseif signal[1][1] == 'long' then
				sendTransaction(
					trans(
						asset, 'B', 
						price_to_buy + 100 * price_step,
						lots_for_trade
					)
				)			
			end
		end
	sleep(2000)	
	end
	
	limits, price = depo_limits(asset)
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	if signal and limits ~= 0 and (quantity_in_stop(asset) == 0 or quantity_in_stop(asset) == nil) 
	and #signal ~= 0 and signal[1][1] and signal[1][2] and signal[1][3] then
		dist_to_stop = tonumber(signal[1][3]) - math.fmod(tonumber(signal[1][3]), price_step)
		dist_to_profit = tonumber(signal[1][2]) - math.fmod(tonumber(signal[1][2]), price_step)
		if limits < 0 then
			sendTransaction(
				stop_trans(
					'B', price - dist_to_profit, 
					math.abs(limits) / lot_size, 
					price + 50 * price_step, 
					price + dist_to_stop, 
					asset, price_step
				)
			)
		elseif limits > 0 then
			sendTransaction(
				stop_trans(
					'S', price + dist_to_profit, 
					math.abs(limits) / lot_size, 
					price - 50 * price_step, 
					price - dist_to_stop, 
					asset, price_step
				)
			)
		end
		file_with_signal = data_path..'/'..asset..'/signal.csv'
		if file_with_signal then
			os.remove(file_with_signal)
		end
	end
	
	sleep(100)
end

IsRun = true

function main()	
    while true do
		for i=1, #assets do
			run(assets[i])
		end
	end
end

function OnStop()
	for i=1, #assets do
		os.remove(data_path..'/'..assets[i]..'/signal.csv')
	end
	IsRun = false
end





