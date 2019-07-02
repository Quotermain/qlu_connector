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
require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

assets = {
		--[["MGNT",
		"TATN",
		"SBERP",
		"MTLR",]]
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
	
	cur = assert(
		conn:execute(
			string.format(
				[[SELECT * FROM trade_signals WHERE asset = '%s']], 
				asset
			)
		)
	)
	row = cur:fetch({}, 'a')

	Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	stakan=getQuoteLevel2("TQBR",asset)
	if stakan~=nil then
		price_to_buy=stakan.offer[1].price
		price_to_sell=stakan.bid[10].price
	end
	limits, price = depo_limits(asset)
	
	--message(tostring(math.floor(Money * 0.0001 / (tonumber(row.dist_to_max) * lot_size))))
	--sleep(5000)
	
	if (limits == 0 or limits == nil) 
	and (order_limits(asset) == 0 or order_limits(asset) == nil) then
		if row.signal == 'short' then
			dist_to_stop = tonumber(row.dist_to_max)
			lots_for_trade = math.floor(Money * 0.0001 / (dist_to_stop * lot_size))
			sendTransaction(
				trans(
					asset, 'S', 
					price_to_sell - 100 * price_step,
					lots_for_trade
				)
			)
		elseif row.signal == 'long' then
			dist_to_stop = tonumber(row.dist_to_min)
			lots_for_trade = math.floor(Money * 0.0001 / (dist_to_stop * lot_size))
			sendTransaction(
				trans(
					asset, 'B', 
					price_to_buy + 100 * price_step,
					lots_for_trade
				)
			)			
		end
	end
	
	limits, price = depo_limits(asset)
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	if limits ~= 0 and (quantity_in_stop(asset) == 0 or quantity_in_stop(asset) == nil) then
		if limits < 0 then
			dist_to_stop = tonumber(row.dist_to_max) - math.fmod(tonumber(row.dist_to_max), price_step)
			dist_to_profit = tonumber(row.dist_to_min) - math.fmod(tonumber(row.dist_to_min), price_step)
			sendTransaction(
				stop_trans(
					'B', price - dist_to_profit, 
					math.abs(limits) / lot_size, 
					price + dist_to_stop + 10 * price_step, 
					price + dist_to_stop, 
					asset, price_step
				)
			)
		elseif limits > 0 then
			dist_to_stop = tonumber(row.dist_to_min) - math.fmod(tonumber(row.dist_to_min), price_step)
			dist_to_profit = tonumber(row.dist_to_max) - math.fmod(tonumber(row.dist_to_max), price_step)
			sendTransaction(
				stop_trans(
					'S', price + dist_to_profit, 
					math.abs(limits) / lot_size, 
					price - dist_to_stop - 10 * price_step, 
					price - dist_to_stop, 
					asset, price_step
				)
			)
		end
		sleep(1000)
		res = assert(
			conn:execute(
				string.format(
					[[UPDATE trade_signals 
					SET `signal` = NULL, `dist_to_max` = NULL, `dist_to_min` = NULL 
					WHERE `asset` = '%s']], 
					asset
				)
			)
		)
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
	IsRun = false
end





