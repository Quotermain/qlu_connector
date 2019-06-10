require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

timeframes = {
	INTERVAL_TICK, 
  --INTERVAL_M1,
  --INTERVAL_M2,
  --INTERVAL_M3,
  --INTERVAL_M4,
  --INTERVAL_M5,
  --INTERVAL_M6,
  --INTERVAL_M10,
  --INTERVAL_M15,
  --INTERVAL_M20,
  --INTERVAL_M30,
  --INTERVAL_H1,
  --INTERVAL_H2,
  --INTERVAL_H4
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
				[[DROP TABLE %s]], assets[i]
			)
		)
	)
end

for i = 1, #assets do
	res = assert(
		conn:execute(
			string.format(
				[[CREATE TABLE IF NOT EXISTS %s(
					date_time TEXT,
					offer_price_10 FLOAT,
					offer_price_9 FLOAT,
					offer_price_8 FLOAT,
					offer_price_7 FLOAT,
					offer_price_6 FLOAT,
					offer_price_5 FLOAT,
					offer_price_4 FLOAT,
					offer_price_3 FLOAT,
					offer_price_2 FLOAT,
					offer_price_1 FLOAT,
					bid_price_10 FLOAT,
					bid_price_9 FLOAT,
					bid_price_8 FLOAT,
					bid_price_7 FLOAT,
					bid_price_6 FLOAT,
					bid_price_5 FLOAT,
					bid_price_4 FLOAT,
					bid_price_3 FLOAT,
					bid_price_2 FLOAT,
					bid_price_1 FLOAT,
					offer_count_10 INT,
					offer_count_9 INT,
					offer_count_8 INT,
					offer_count_7 INT,
					offer_count_6 INT,
					offer_count_5 INT,
					offer_count_4 INT,
					offer_count_3 INT,
					offer_count_2 INT,
					offer_count_1 INT,
					bid_count_10 INT,
					bid_count_9 INT,
					bid_count_8 INT,
					bid_count_7 INT,
					bid_count_6 INT,
					bid_count_5 INT,
					bid_count_4 INT,
					bid_count_3 INT,
					bid_count_2 INT,
					bid_count_1 INT,
					close FLOAT,
					volume FLOAT
				)]], assets[i])
		)
	)
end

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
