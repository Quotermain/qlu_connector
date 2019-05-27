require 'utils/string_split'
require 'utils/read_from_file'
require 'utils/quantity_in_stop'
require 'utils/id_of_stop_to_kill'
require 'utils/killstop_trans'
require 'utils/stop_trans'
require 'utils/getLotSizeBySecCode'
require 'utils/PRICE_STEP'

--Надо одну стоп заявку. Посылает две.
function OnOrder(order)
	if (quantity_in_stop('ALRS')==0 or quantity_in_stop('ALRS')==nil) then
		if bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 then
			if bit.band(order.flags,4)>1 then
				sendTransaction(
					stop_trans(
						'B', 0.535, order.qty, 0.535, 0.5410, order.sec_code, 0.01
					)
				)
				--message('Sell')
			elseif bit.band(order.flags,4)==0 then
				sendTransaction(
					stop_trans(
						'S', 0.5410, order.qty, 0.5410, 0.535, order.sec_code, 0.01
					)
				)
				--message('Buy')
			end
		end
	end
end

data_path = 'C:/Users/Quotermain233/Desktop/VBShared/test/'
function run(asset)

	stop_items = SearchItems("stop_orders", 0, getNumberOf("stop_orders")-1, items_in_table)
	if stop_items ~= nil and #stop_items>1 then
		sendTransaction(
			killstop_trans(
				asset, quantity_in_stop(asset), id_of_stop_to_kill(asset)
			)
		)
	end
		
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
		
	sleep(1000)
end

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

function main()	
    while true do
		for i=1, #assets do
			run(assets[i])
		end
	end
end