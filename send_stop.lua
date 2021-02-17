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
--require "luasql.mysql"

--Mean + std
assets = {
		['BANE']=0.00354, --17
		['AFLT']=0.00438, --32
		['OGKB']=0.004253, --32
		["MGNT"]=0.00329, --5
		["TATN"]=0.003087, --63
		["SBERP"]=0.002977, --13
		["MTLR"]=0.003546, --438
		["ALRS"]=0.003467, --30
		["SBER"]=0.002908, --12
		["MOEX"]=0.002559, --24
		["HYDR"]=0.003046, --42
		["ROSN"]=0.002588, --9,
		["LKOH"]=0.003546, --6
		["SIBN"]=0.002956, --10,
		["GMKN"]=0.002844, --1,
		["RTKM"]=0.003029, --35,
		["SNGS"]=0.003546, --8,
		["SNGSP"]=0.003546, --7,
		["CHMF"]=0.002979,  --26,
		["VTBR"]=0.003101, --87,
		["NVTK"]=0.003231, --26,
		["GAZP"]=0.002355, --20,
		['NLMK']=0.003546, --13
		["MTSS"]=0.003546, --9
		["YNDX"]=0.003546, --5
		['FIVE']=0.003546 --10
}


function run(asset)

	limits, price = depo_limits(asset)
	lot_size = getLotSizeBySecCode(asset)
	price_step = PRICE_STEP(asset)

	message(asset)

	--message(tostring(limits))

	--sleep(5000)

	if limits ~= 0 and (quantity_in_stop(asset) == 0 or quantity_in_stop(asset) == nil) then
		if limits < 0 then
			stop_limit_price = price + assets[asset] * price
			stop_limit_price = stop_limit_price - math.fmod(stop_limit_price, price_step)
			take_profit_price = price - assets[asset] * price
			take_profit_price = take_profit_price - math.fmod(take_profit_price, price_step)
			sendTransaction(
				stop_trans(
					'B', take_profit_pricet,
					math.abs(limits) / lot_size,
					stop_limit_price + 10 * price_step,
					stop_limit_price,
					asset, price_step
				)
			)
		elseif limits > 0 then
			stop_limit_price = price - assets[asset] * price
			stop_limit_price = stop_limit_price - math.fmod(stop_limit_price, price_step)
			take_profit_price = price + assets[asset] * price
			take_profit_price = take_profit_price - math.fmod(take_profit_price, price_step)
			sendTransaction(
				stop_trans(
					'S', take_profit_price,
					math.abs(limits) / lot_size,
					stop_limit_price - 10 * price_step,
					stop_limit_price,
					asset, price_step
				)
			)
		end
		sleep(1000)
	end
end

IsRun = true

function main()
    while IsRun do
		for key, value in pairs(assets) do
			--message(key)
			--sleep(5000)
			run(key)
		end
	end
end

function OnStop()
	IsRun = false
end
