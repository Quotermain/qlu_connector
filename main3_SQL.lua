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

function run(asset)
	Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)
	--[[dist_to_stop = tonumber(signal[1][3])
	lots_for_trade = math.floor(Money * 0.0001 / (dist_to_stop * lot_size))
	stakan=getQuoteLevel2("TQBR",asset)
	if stakan~=nil then
		price_to_buy=stakan.offer[1].price
		price_to_sell=stakan.bid[10].price
	end]]
	limits, price = depo_limits(asset)
	
	cur = assert(
		conn:execute(
			string.format(
				[[SELECT * FROM trade_signals WHERE asset = '%s']], 
				asset
			)
		)
	)
	row = cur:fetch({}, 'a')
	
	message(tostring(row.dist_to_max))

	sleep(1000)
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





