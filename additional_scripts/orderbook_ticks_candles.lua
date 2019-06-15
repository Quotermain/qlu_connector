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
	for i = 1, 15 do
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
			key..'low FLOAT, '
	end
	result_query = result_query.."close FLOAT, volume FLOAT)"
	res = assert(
		conn:execute(
			string.format(
				result_query, assets[i]
			)
		)
	)
end

message('done')
sleep(10000)

function OnInit()

    function DATA(ACTIVE)
	
		for i=1, #timeframes do
		
			ds1 = CreateDataSource('TQBR', ACTIVE, timeframes[i])
			ds1:SetEmptyCallback()
			
			stakan=getQuoteLevel2("TQBR",ACTIVE)
			
			res = assert(
				conn:execute(
					string.format(
						[[INSERT INTO %s 
						(
							date_time,
							offer_price_10,
							offer_price_9,
							offer_price_8,
							offer_price_7,
							offer_price_6,
							offer_price_5,
							offer_price_4,
							offer_price_3,
							offer_price_2,
							offer_price_1,
							bid_price_10,
							bid_price_9,
							bid_price_8,
							bid_price_7,
							bid_price_6,
							bid_price_5,
							bid_price_4,
							bid_price_3,
							bid_price_2,
							bid_price_1,
							offer_count_10,
							offer_count_9,
							offer_count_8,
							offer_count_7,
							offer_count_6,
							offer_count_5,
							offer_count_4,
							offer_count_3,
							offer_count_2,
							offer_count_1,
							bid_count_10,
							bid_count_9,
							bid_count_8,
							bid_count_7,
							bid_count_6,
							bid_count_5,
							bid_count_4,
							bid_count_3,
							bid_count_2,
							bid_count_1,
							close,
							volume
						)
						VALUES (
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s', 
							'%s', '%s', '%s'  							
						)]],
							ACTIVE,
							tostring(
								ds1:T(ds1:Size()).year..'-'..
								ds1:T(ds1:Size()).month..'-'..
								ds1:T(ds1:Size()).day..' '..
								ds1:T(ds1:Size()).hour..':'..
								ds1:T(ds1:Size()).min..':'..
								ds1:T(ds1:Size()).sec
							),
							stakan.offer[10].price,
							stakan.offer[9].price,
							stakan.offer[8].price,
							stakan.offer[7].price,
							stakan.offer[6].price,
							stakan.offer[5].price,
							stakan.offer[4].price,
							stakan.offer[3].price,
							stakan.offer[2].price,
							stakan.offer[1].price,
							stakan.bid[20].price,
							stakan.bid[19].price,
							stakan.bid[18].price,
							stakan.bid[17].price,
							stakan.bid[16].price,
							stakan.bid[15].price,
							stakan.bid[14].price,
							stakan.bid[13].price,
							stakan.bid[12].price,
							stakan.bid[11].price,
							stakan.offer[10].quantity,
							stakan.offer[9].quantity, 
							stakan.offer[8].quantity, 
							stakan.offer[7].quantity, 
							stakan.offer[6].quantity, 
							stakan.offer[5].quantity, 
							stakan.offer[4].quantity, 
							stakan.offer[3].quantity, 
							stakan.offer[2].quantity,
							stakan.offer[1].quantity, 
							stakan.bid[20].quantity,
							stakan.bid[19].quantity,
							stakan.bid[18].quantity,
							stakan.bid[17].quantity,
							stakan.bid[16].quantity,
							stakan.bid[15].quantity,
							stakan.bid[14].quantity,
							stakan.bid[13].quantity,
							stakan.bid[12].quantity,
							stakan.bid[11].quantity,
							ds1:C(ds1:Size()),
							ds1:V(ds1:Size())
						)
				)
			)

		end
	
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
