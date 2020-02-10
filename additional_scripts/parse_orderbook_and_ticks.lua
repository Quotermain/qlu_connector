require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

timeframes = {
	--INTERVAL_TICK, 
  INTERVAL_M1,
  INTERVAL_M2,
  INTERVAL_M3,
  INTERVAL_M4,
  INTERVAL_M5,
  INTERVAL_M6,
  INTERVAL_M10,
  INTERVAL_M15,
  INTERVAL_M20,
  INTERVAL_M30,
  INTERVAL_H1,
  INTERVAL_H2,
  INTERVAL_H4
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

--[[
for i = 1, #assets do
	res = assert(
		conn:execute(
			string.format(
				"DROP TABLE IF EXISTS %s_train", assets[i]
			)
		)
	)
end
]]

for i = 1, #assets do
	res = assert(
		conn:execute(
			string.format(
				[[CREATE TABLE IF NOT EXISTS %s_train(
					date_time DATETIME,
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
					1_open FLOAT,
					1_high FLOAT,
					1_low FLOAT,
					1_volume FLOAT,
					2_open FLOAT,
					2_high FLOAT,
					2_low FLOAT,
					2_volume FLOAT,
					3_open FLOAT,
					3_high FLOAT,
					3_low FLOAT,
					3_volume FLOAT,
					4_open FLOAT,
					4_high FLOAT,
					4_low FLOAT,
					4_volume FLOAT,
					5_open FLOAT,
					5_high FLOAT,
					5_low FLOAT,
					5_volume FLOAT,
					6_open FLOAT,
					6_high FLOAT,
					6_low FLOAT,
					6_volume FLOAT,
					10_open FLOAT,
					10_high FLOAT,
					10_low FLOAT,
					10_volume FLOAT,
					15_open FLOAT,
					15_high FLOAT,
					15_low FLOAT,
					15_volume FLOAT,
					20_open FLOAT,
					20_high FLOAT,
					20_low FLOAT,
					20_volume FLOAT,
					30_open FLOAT,
					30_high FLOAT,
					30_low FLOAT,
					30_volume FLOAT,
					60_open FLOAT,
					60_high FLOAT,
					60_low FLOAT,
					60_volume FLOAT,
					120_open FLOAT,
					120_high FLOAT,
					120_low FLOAT,
					120_volume FLOAT,
					240_open FLOAT,
					240_high FLOAT,
					240_low FLOAT,
					240_volume FLOAT,
					close FLOAT
				)]], assets[i])
		)
	)
end

function OnInit()

    function DATA(ACTIVE)
		
		ds1 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M1)
		
		ds2 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M2)
		
		ds3 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M3)
		
		ds4 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M4)
	
		ds5 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M5)
		
		ds6 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M6)
		
		ds10 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M10)
		
		ds15 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M15)
		
		ds20 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M20)
		
		ds30 = CreateDataSource('TQBR', ACTIVE, INTERVAL_M30)
		
		ds60 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H1)
		
		ds120 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H2)
		
		ds240 = CreateDataSource('TQBR', ACTIVE, INTERVAL_H4)
		
		stakan=getQuoteLevel2("TQBR",ACTIVE)
		
		for i=1, #timeframes do
			
			ds1:SetEmptyCallback()
			
			ds2:SetEmptyCallback()
			
			ds3:SetEmptyCallback()
			
			ds4:SetEmptyCallback()
		
			ds5:SetEmptyCallback()
			
			ds6:SetEmptyCallback()
			
			ds10:SetEmptyCallback()
			
			ds15:SetEmptyCallback()
			
			ds20:SetEmptyCallback()

			ds30:SetEmptyCallback()
			
			ds60:SetEmptyCallback()
			
			ds120:SetEmptyCallback()
			
			ds240:SetEmptyCallback()
			
			stakan=getQuoteLevel2("TQBR",ACTIVE)
			
			res = assert(
				conn:execute(
					string.format(
						[[INSERT INTO %s_train 
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
							1_open,
							1_high,
							1_low,
							1_volume,
							2_open,
							2_high,
							2_low,
							2_volume,
							3_open,
							3_high,
							3_low,
							3_volume,
							4_open,
							4_high,
							4_low,
							4_volume,
							5_open,
							5_high,
							5_low,
							5_volume,
							6_open,
							6_high,
							6_low,
							6_volume,
							10_open,
							10_high,
							10_low,
							10_volume,
							15_open,
							15_high,
							15_low,
							15_volume,
							20_open,
							20_high,
							20_low,
							20_volume,
							30_open,
							30_high,
							30_low,
							30_volume,
							60_open,
							60_high,
							60_low,
							60_volume,
							120_open,
							120_high,
							120_low,
							120_volume,
							240_open,
							240_high,
							240_low,
							240_volume,
							close
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
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s', '%s', 
							'%s', '%s', '%s', '%s', '%s',
							'%s', '%s', '%s', '%s'
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
							ds1:O(ds1:Size()),
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
			--message(tostring(stakan.offer[1].price))
			--sleep(100)
			
		end
	--sleep(2000)
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
