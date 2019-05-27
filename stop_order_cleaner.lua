require 'utils/quantity_in_stop'
require 'utils/id_of_stop_to_kill'
require 'utils/killstop_trans'
require 'utils/stop_trans'

function run(asset)

	function items_in_table(t)
		if t.sec_code == asset and bit.band(t.flags,1)>0 then
			return true
		else 
			return false
		end
	end
	
	stop_items = SearchItems("stop_orders", 0, getNumberOf("stop_orders")-1, items_in_table)
	if stop_items ~= nil and #stop_items>1 then
		sendTransaction(
			killstop_trans(
				asset, quantity_in_stop(asset), id_of_stop_to_kill(asset)
			)
		)
	end
	
	sleep(100)
	
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