require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

timeframes = {
	--['0_'] = INTERVAL_TICK, 
	['1_'] = INTERVAL_M1,
	['2_'] = INTERVAL_M2,
	['3_'] = INTERVAL_M3,
	['4_'] = INTERVAL_M4,
	['5_'] = INTERVAL_M5,
	['6_'] = INTERVAL_M6,
	['10_'] = INTERVAL_M10,
	['15_'] = INTERVAL_M15,
	['20_'] = INTERVAL_M20,
	['30_'] = INTERVAL_M30,
	['60_'] = INTERVAL_H1,
	['120_'] = INTERVAL_H2,
	['240_'] = INTERVAL_H4
}

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


for i = 1, #assets do
	res = assert(
		conn:execute(
			string.format(
				[[DROP TABLE %s_train]], assets[i]
			)
		)
	)
end

for i = 1, #assets do
	result_query = "CREATE TABLE IF NOT EXISTS %s_train(date_time DATETIME, "
	for i = 1, 9 do
		result_query = result_query..
			'offer_price_'..tostring(i)..' FLOAT,'..
			'bid_price_'..tostring(i)..' FLOAT,'..
			'offer_count_'..tostring(i)..' INT,'..
			'bid_count_'..tostring(i)..' INT, '
	end
	for key, value in pairs(timeframes) do
		result_query = result_query..
			key..'open FLOAT, '..
			key..'high FLOAT, '..
			key..'low FLOAT, '..
			key..'volume FLOAT, '
	end
	result_query = result_query.."close FLOAT)"
	res = assert(
		conn:execute(
			string.format(
				result_query, assets[i]
			)
		)
	)
end

function OnInit()

    function DATA(ACTIVE)
			
		ds1 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M1)
		ds1:SetEmptyCallback()
			
		ds2 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M2)
		ds2:SetEmptyCallback()
			
		ds3 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M3)
		ds3:SetEmptyCallback()
			
		ds4 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M4)
		ds4:SetEmptyCallback()
		
		ds5 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M5)
		ds5:SetEmptyCallback()
			
		ds6 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M6)
		ds6:SetEmptyCallback()
			
		ds10 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M10)
		ds10:SetEmptyCallback()
			
		ds15 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M15)
		ds15:SetEmptyCallback()
			
		ds20 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M20)
		ds20:SetEmptyCallback()
			
		ds30 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M30)
		ds30:SetEmptyCallback()
			
		ds60 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H1)
		ds60:SetEmptyCallback()
			
		ds120 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H2)
		ds120:SetEmptyCallback()
			
		ds240 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H4)
		ds240:SetEmptyCallback()
			
		stakan=getQuoteLevel2("TQBR",ACTIVE)
		
		result_query = "INSERT INTO %s_train(date_time, "
		stakan_array = {}
		for i = 1, 9 do
			result_query = result_query..
				'offer_price_'..tostring(i)..','..
				'bid_price_'..tostring(i)..','..
				'offer_count_'..tostring(i)..','..
				'bid_count_'..tostring(i)..','
			table.insert(stakan_array, stakan.offer[i].price)
			table.insert(stakan_array, stakan.bid[i].price)
			table.insert(stakan_array, stakan.offer[i].quantity)
			table.insert(stakan_array, stakan.bid[i].quantity)
		end

		for key, value in pairs(timeframes) do
			result_query = result_query..
				key..'open '..','..
				key..'high '..','..
				key..'low '..','..
				key..'volume'..','
		end
		result_query = result_query.."close) VALUES ("..string.rep("'%s', ", 100).."'%s')" --calculate number of placeholders
		message(result_query)
		sleep(5000)
		res = assert(
			conn:execute(
				string.format(
					result_query, 
					ACTIVE,
					tostring(
						ds1:T(ds1:Size()).year..'-'..
						ds1:T(ds1:Size()).month..'-'..
						ds1:T(ds1:Size()).day..' '..
						ds1:T(ds1:Size()).hour..':'..
						ds1:T(ds1:Size()).min..':'..
						ds1:T(ds1:Size()).sec
					), unpack(stakan_array),
					tostring(ds1:O(ds1:Size())),
					ds1:H(ds1:Size()),
					ds1:L(ds1:Size()),
					ds1:V(ds1:Size()),
					ds2:O(ds2:Size()),
					ds2:H(ds2:Size()),
					ds2:L(ds2:Size()),
					ds2:V(ds2:Size()),
					ds3:O(ds3:Size()),
					ds3:H(ds3:Size()),
					ds3:L(ds3:Size()),
					ds3:V(ds3:Size()),
					ds4:O(ds4:Size()),
					ds4:H(ds4:Size()),
					ds4:L(ds4:Size()),
					ds4:V(ds4:Size()),
					ds5:O(ds5:Size()),
					ds5:H(ds5:Size()),
					ds5:L(ds5:Size()),
					ds5:V(ds5:Size()),
					ds6:O(ds6:Size()),
					ds6:H(ds6:Size()),
					ds6:L(ds6:Size()),
					ds6:V(ds6:Size()),
					ds10:O(ds10:Size()),
					ds10:H(ds10:Size()),
					ds10:L(ds10:Size()),
					ds10:V(ds10:Size()),
					ds15:O(ds15:Size()),
					ds15:H(ds15:Size()),
					ds15:L(ds15:Size()),
					ds15:V(ds15:Size()),
					ds20:O(ds20:Size()),
					ds20:H(ds20:Size()),
					ds20:L(ds20:Size()),
					ds20:V(ds20:Size()),
					ds30:O(ds30:Size()),
					ds30:H(ds30:Size()),
					ds30:L(ds30:Size()),
					ds30:V(ds30:Size()),
					ds60:O(ds60:Size()),
					ds60:H(ds60:Size()),
					ds60:L(ds60:Size()),
					ds60:V(ds60:Size()),
					ds120:O(ds120:Size()),
					ds120:H(ds120:Size()),
					ds120:L(ds120:Size()),
					ds120:V(ds120:Size()),
					ds240:O(ds240:Size()),
					ds240:H(ds240:Size()),
					ds240:L(ds240:Size()),
					ds240:V(ds240:Size()),
					ds1:C(ds1:Size())

				)
			)
		)


	
    end
	
end
 
 IsRun = true
 -- Основная функция скрипта (пока работает она, работает скрипт)
function main()
	while IsRun do
	    DATA("MGNT")
		DATA("TATN")
		DATA("SBERP")
		DATA("MTLR")
		DATA("ALRS")
		DATA("SBER")
		DATA("MOEX")
		DATA("HYDR")
		DATA("ROSN")
		DATA("LKOH")
		DATA("SIBN")
		DATA("GMKN")
		DATA("RTKM")
		DATA("SNGS")
		DATA("SNGSP")
		DATA("CHMF")
		DATA("NVTK")
		DATA("GAZP")
		DATA("MTSS")
		DATA("YNDX")
		--message("Done")
		--break
	end
end;
 

function OnStop()
	IsRun = false;
end;
