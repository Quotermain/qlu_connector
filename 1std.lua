require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trades", "root", "password", "localhost", 3306))


-- print all rows, the rows will be indexed by field names
--row = cur:fetch ({}, "a")

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

number=nil
table_of_selled={}
table_of_buyed={}
function OnOrder(order)
    number=order.order_num
    if bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 and bit.band(order.flags,4)==0
    then 
	    number=order.order_num 
		table_of_buyed[number]=order.sec_code
    elseif bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 and bit.band(order.flags,4)>0 
	then 
	    number=order.order_num 
		table_of_selled[number]=order.sec_code
    end
end

function CheckBit(flags, bit)
   -- Проверяет, что переданные аргументы являются числами
   if type(flags) ~= "number" then error("Ошибка!!! Checkbit: 1-й аргумент не число!"); end;
   if type(bit) ~= "number" then error("Ошибка!!! Checkbit: 2-й аргумент не число!"); end;
   local RevBitsStr  = ""; -- Перевернутое (задом наперед) строковое представление двоичного представления переданного десятичного числа (flags)
   local Fmod = 0; -- Остаток от деления 
   local Go = true; -- Флаг работы цикла
   while Go do
      Fmod = math.fmod(flags, 2); -- Остаток от деления
      flags = math.floor(flags/2); -- Оставляет для следующей итерации цикла только целую часть от деления           
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- Добавляет справа остаток от деления
      if flags == 0 then Go = false; end; -- Если был последний бит, завершает цикл
   end;
   -- Возвращает значение бита
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;     
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;


table_of_trades = {}
function OnTrade(trade)
  
  local lot_size = 0
  if trade.sec_code == "MGNT" then
    lot_size = 1
  elseif 
    trade.sec_code == "TATN" then
    lot_size = 10
  elseif 
    trade.sec_code == "SBERP" then
    lot_size = 100
  elseif 
    trade.sec_code == "MTLR" then
    lot_size = 1
  elseif 
    trade.sec_code == "ALRS" then
    lot_size = 100
  elseif 
    trade.sec_code == "SBER" then
    lot_size = 10
  elseif 
    trade.sec_code == "MOEX" then
    lot_size = 10
  elseif 
    trade.sec_code == "HYDR" then
    lot_size = 1000
  elseif 
    trade.sec_code == "ROSN" then
    lot_size = 10
  elseif 
    trade.sec_code == "LKOH" then
    lot_size = 1
  elseif 
    trade.sec_code == "SIBN" then
    lot_size = 10
  elseif 
    trade.sec_code == "GMKN" then
    lot_size = 1
  elseif 
    trade.sec_code == "RTKM" then
    lot_size = 10
  elseif 
    trade.sec_code == "SNGS" then
    lot_size = 100
  elseif 
    trade.sec_code == "SNGSP" then
    lot_size = 100
  elseif 
    trade.sec_code == "CHMF" then
    lot_size = 10
  elseif 
    trade.sec_code == "NVTK" then
    lot_size = 10
  elseif 
    trade.sec_code == "GAZP" then
    lot_size = 10
  elseif 
    trade.sec_code == "MTSS" then
    lot_size = 10
  elseif 
    trade.sec_code == "YNDX" then
    lot_size = 1
  end
  
  local Operation = "";
  if CheckBit(trade.flags, 2) == 1 then Operation = "Sell"; else Operation = "Buy"; end;
  if table_of_trades[trade.sec_code] == nil then

    table_of_trades[trade.sec_code] = {
	                                    trade_num = trade.trade_num,
	                                    date_open = tostring(os.date("%d.%m.%Y")),
									    direction = Operation,
									    time_opened = tostring(os.date("%X")),
									    time_closed = '',
									    security = trade.sec_code,
										quant = 0,
									    price_opened = trade.price,
									    price_closed = 0,
										result = 0,
										quant_2 = 0
									   }
  end;
   
  if table_of_trades[trade.sec_code] ~= nil then
    if Operation == "Buy" then 
      if table_of_trades[trade.sec_code].direction == "Buy" then
	    table_of_trades[trade.sec_code].quant = table_of_trades[trade.sec_code].quant + trade.qty
		table_of_trades[trade.sec_code].quant_2 = table_of_trades[trade.sec_code].quant
		cur = assert (conn:execute(string.format([[SELECT * FROM all_trades WHERE id = %s
		  OR (instrument='%s' AND price_closed IS NULL)]],
		  trade.trade_num, trade.sec_code)
		))
		row = cur:fetch (row, "a")
		if row == nil then
		  res = assert (conn:execute(string.format([[
            INSERT INTO all_trades (id, instrument, quantity, time_opened, direction, price_opened)
            VALUES ('%s', '%s', '%s', '%s', '%s', '%s')]], 
		      trade.trade_num, trade.sec_code, trade.qty * lot_size, 
			  tostring(os.date("%d.%m.%Y"))..' '..tostring(os.date("%X")),
			  Operation, round(trade.price, 4))
          ))
		end
	  elseif table_of_trades[trade.sec_code].direction == "Sell" then
	    table_of_trades[trade.sec_code].quant = table_of_trades[trade.sec_code].quant - trade.qty
	  end
    elseif Operation == "Sell" then
      if table_of_trades[trade.sec_code].direction == "Buy" then
	    table_of_trades[trade.sec_code].quant = table_of_trades[trade.sec_code].quant - trade.qty
	  elseif table_of_trades[trade.sec_code].direction == "Sell" then
	    table_of_trades[trade.sec_code].quant = table_of_trades[trade.sec_code].quant + trade.qty
		table_of_trades[trade.sec_code].quant_2 = table_of_trades[trade.sec_code].quant
		cur = assert (conn:execute(string.format([[SELECT * FROM all_trades WHERE id = %s]],
		  trade.trade_num)
		))
		row = cur:fetch (row, "a")
		if row == nil then
		  res = assert (conn:execute(string.format([[
            INSERT INTO all_trades (id, instrument, quantity, time_opened, direction, price_opened)
            VALUES ('%s', '%s', '%s', '%s', '%s', '%s')]], 
		      trade.trade_num, trade.sec_code, trade.qty * lot_size, 
			  tostring(os.date("%d.%m.%Y"))..' '..tostring(os.date("%X")),
			  Operation, trade.price)
          ))
		end
	  end
    end
  end

  if table_of_trades[trade.sec_code].quant == 0 then
    table_of_trades[trade.sec_code].time_closed = tostring(os.date("%X"))
    table_of_trades[trade.sec_code].price_closed = trade.price
	if table_of_trades[trade.sec_code].direction == "Buy" then
	  table_of_trades[trade.sec_code].result = (table_of_trades[trade.sec_code].price_closed - table_of_trades[trade.sec_code].price_opened) * 
	   lot_size * table_of_trades[trade.sec_code].quant_2 / 3
	   res = assert (conn:execute(string.format([[
            UPDATE all_trades SET price_closed = %s, result = %s, time_closed = '%s' WHERE id = %s]], 
		      trade.price,
			  table_of_trades[trade.sec_code].result,
			  tostring(os.date("%d.%m.%Y"))..' '..tostring(os.date("%X")),
			  table_of_trades[trade.sec_code].trade_num)
       ))
	   table_of_trades[trade.sec_code] = nil
	elseif table_of_trades[trade.sec_code].direction == "Sell" then
	  table_of_trades[trade.sec_code].result = (table_of_trades[trade.sec_code].price_opened - table_of_trades[trade.sec_code].price_closed) * 
	   lot_size * table_of_trades[trade.sec_code].quant_2 /3
	   res = assert (conn:execute(string.format([[
            UPDATE all_trades SET price_closed = %s, result = %s, time_closed = '%s' WHERE id = %s]], 
		      trade.price,
			  table_of_trades[trade.sec_code].result,
			  tostring(os.date("%d.%m.%Y"))..' '..tostring(os.date("%X")),
			  table_of_trades[trade.sec_code].trade_num)
       ))
	   table_of_trades[trade.sec_code] = nil
	end
  end
end


function MA_function(source)
    
	table_of_candles2_left_screen={} --заполняем массив ценами открытия или закрытия (зависит от того, какая меньше)
    for i=1,100,1 do
        table_of_candles2_left_screen[i]=source:C(source:Size()-100+i)
    end
    
	table_of_slow={}
    table_of_slow[1]=table_of_candles2_left_screen[1]
    for i=2,100,1 do
        table_of_slow[i]=(2/(26+1))*table_of_candles2_left_screen[i]+(1-(2/(26+1)))*table_of_slow[i-1]
    end
    
	table_of_fast={}
    table_of_fast[1]=table_of_candles2_left_screen[1]
    for i=2,100,1 do
        table_of_fast[i]=(2/(13+1))*table_of_candles2_left_screen[i]+(1-(2/(13+1)))*table_of_fast[i-1]
    end
	
	local table_of_razn = {}
	for i = 1, 100 do
	  table_of_razn[i] = math.abs(table_of_fast[i] - table_of_candles2_left_screen[i])
	end
	
	local aver_deviation = aver(unpack(table_of_razn, 1, 100))
	
	return table_of_fast[100], table_of_slow[100], table_of_candles2_left_screen[100], aver_deviation
end

function EFI_function(source, number)
    table_of_EFI2={}
    table_of_EFI2[1]=(1-source:C(source:Size()-50-1)/source:C(source:Size()-50))*source:V(source:Size()-50)
    for i=2,50,1 do
	    table_of_EFI2[i]=(2/(13+1))*((1-source:C(source:Size()-50+i-1)/source:C(source:Size()-50+i))*source:V(source:Size()-50+i))+(1-(2/(13+1)))*table_of_EFI2[i-1]
    end
	table_of_EFI_minus = {}
	table_of_EFI_plus = {}
	for i in pairs(table_of_EFI2) do
		if table_of_EFI2[i] < 0 then
			table.insert(table_of_EFI_minus, math.abs(table_of_EFI2[i]))
	    else
			table.insert(table_of_EFI_plus, table_of_EFI2[i])
		end
	end
	table_of_EFI_normalized = {}
	for i in pairs(table_of_EFI2) do
		if table_of_EFI2[i] < 0 then
			table_of_EFI_normalized[i] =-(math.abs(table_of_EFI2[i]) - math.min(unpack(table_of_EFI_minus)))/(math.max(unpack(table_of_EFI_minus)) - math.min(unpack(table_of_EFI_minus)))
		else
			table_of_EFI_normalized[i] =(table_of_EFI2[i] - math.min(unpack(table_of_EFI_plus)))/(math.max(unpack(table_of_EFI_plus)) - math.min(unpack(table_of_EFI_plus)))
		end
    end
	return table_of_EFI_normalized[number]
	
end

function RSI_function(source)
    ClosePrice={} 
    for i=1,28,1 do
	    ClosePrice[i]=source:C(source:Size()-28+i)
    end
	deltas = {}
	for i = 2, 28 do
	    deltas[i] = ClosePrice[i] - ClosePrice[i-1]
	end
	seed = {}
	for i = 1, 14 do
	    seed[i] = deltas[i]
	end
	up = {}
	down = {}
	for i in pairs(seed) do
	    if seed[i] >= 0 then
		    table.insert(up, seed[i])
		else
		    table.insert(down, seed[i])
		end
	end
	up = sum(unpack(up))/14
	down = -sum(unpack(down))/14
	rs = up/down
	rsi = {}
	for i = 1, 14 do
	    rsi[i] = 0
	end
	for i in pairs(rsi) do
	    rsi[i] = 100 - 100/(1 + rs)
	end
	for i = 15, 28 do
	    delta = deltas[i-1]
		if delta > 0 then
		    upval = delta
			downval = 0
		else
		    upval = 0
			downval = -delta
        end
		up = (up*(14-1) + upval)/14
        down = (down*(14-1) + downval)/14
        rs = up/down
        rsi[i] = 100 - 100/(1+rs)
	end
    return rsi[28]
end

function stochastic_function(source)
    local ClosePrice={} 
    for i=1,50,1 do
	    ClosePrice[i]=source:C(source:Size()-50+i)
    end
	local MaximumPrice={}
    for i=1,50,1 do
	    MaximumPrice[i]=source:H(source:Size()-50+i)
    end
	local MinimumPrice={}
    for i=1,50,1 do
	    MinimumPrice[i]=source:L(source:Size()-50+i)
    end
	local table_of_strochastic = {}
	for i=5,50,1 do
	    table_of_strochastic[i]=(ClosePrice[i]-math.min(unpack(MinimumPrice,i-4,i)))/(math.max(unpack(MaximumPrice,i-4,i))-math.min(unpack(MinimumPrice,i-4,i)))
	end
	return aver(unpack(table_of_strochastic, 48, 50))
end

function normalized(sequence, value_for_return)
        table_normalized = {}
        for i = 1, 50 do
		    table_normalized[i] = 2*(sequence[i] - math.min(unpack(sequence)))/(math.max(unpack(sequence)) 
			- math.min(unpack(sequence))) - 1
		end
		return table_normalized[value_for_return]
end

function procentile(value, ...)
    local count = 0
	    for i = 1, arg.n do
		    if arg[i] <= value then
			    count = count + 1
			end
		end
	return count/(#arg)
end

function OnDepoLimit(dlimit)
izm_lim_ACTIVE=dlimit.sec_code izm_lim_bal=dlimit.currentbal
end

function sum_razn(...)
	SUM_RAZN=0
	local arg={...}
	for i = 1, #arg do
        SUM_RAZN=SUM_RAZN+math.abs(arg[i]-arg[i+1])
    end
	return SUM_RAZN
end

function sum(...)
   result = 0
   local arg={...}
   for i,v in ipairs(arg) do
      result = result + v
   end
   return result
end

function aver(...)
   result = 0
   local arg={...}
   for i,v in ipairs(arg) do
      result = result + v
   end
   return result/#arg
end

trans_Status=nil

function OnTransReply(trans_reply)
    trans_Status = trans_reply.status
end

function OnInit()
   function DATA (ACTIVE,PERIOD)

    active_left_screen=CreateDataSource("TQBR",ACTIVE,INTERVAL_H1)
	active_left_screen:SetEmptyCallback()
	active_middle_screen=CreateDataSource("TQBR",ACTIVE,INTERVAL_M15)
	active_middle_screen:SetEmptyCallback()
	active_right_screen=CreateDataSource("TQBR",ACTIVE,INTERVAL_M5)
	active_right_screen:SetEmptyCallback()
	active_fast_screen=CreateDataSource("TQBR",ACTIVE,INTERVAL_M1)
	active_fast_screen:SetEmptyCallback()
	
	
function KILL()
    local t=nil
    local kill=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==ACTIVE and bit.band(t.flags,1)==0x1 then
		    kill=t.order_num
		end
	end
    return kill
end

function ORDER_ID()
    local t=nil
    local kill=nil
	for i=0,getNumberOf("orders")-1 do
		t=getItem("orders",i)
		if t.sec_code==ACTIVE and bit.band(t.flags,1)==0x1 then
		    kill=t.order_num
		end
	end
    return kill
end

function ORDERS_NUMBER()
    local t=nil
    local stop_number=nil
	for i=0,getNumberOf("orders")-1 do
		t=getItem("orders",i)
		if t.sec_code==ACTIVE and bit.band(t.flags,1)>0 then
		    stop_number=t.qty
		end
	end
    return stop_number
end

function QUANT_OF_STOP()
    local t=nil
    local quant_stop=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==ACTIVE and bit.band(t.flags,1)==0x1 then
		    quant_stop=t.qty
		end
	end
    return quant_stop
end
	
function STOP_NUMBER()
local t=nil
local stop_number=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==ACTIVE and bit.band(t.flags,1)>0 then
		stop_number=t.qty
		end
	end
return stop_number
end


	
function PRICE_STEP()
    t=nil
	for i=0,getNumberOf("securities")-1 do
		t=getItem("securities",i)
			if t.code==ACTIVE then
				limit=t.min_price_step 
			end
	end
	return limit
	end

function getLotSizeBySecCode(ACTIVE)
   local status = getParamEx("TQBR", ACTIVE, "lotsize"); -- Беру размер лота для кода класса "TQBR"
   return math.ceil(status.param_value);                   -- Отбрасываю ноли после запятой
end;

ab=nil
ab=getLotSizeBySecCode(ACTIVE)

OpenPrice={} 
for i=1,50,1 do
	OpenPrice[i]=active_middle_screen:O(active_middle_screen:Size()-50+i)
end
		
MaximumPrice={}
for i=1,200,1 do
	MaximumPrice[i]=active_middle_screen:H(active_middle_screen:Size()-200+i)
end
		
MinimumPrice={}
for i=1,200,1 do
	MinimumPrice[i]=active_middle_screen:L(active_middle_screen:Size()-200+i)
end
		
table_of_aver_volatility={}
for i=1,200,1 do
	table_of_aver_volatility[i]=math.abs(MaximumPrice[i]-MinimumPrice[i])
end

aver_volatility=aver(unpack(table_of_aver_volatility))


table_of_EFI1={}
table_of_EFI1[1]=(1-active_right_screen:C(active_right_screen:Size()-50-1)/active_right_screen:C(active_right_screen:Size()-50))*active_right_screen:V(active_right_screen:Size()-50)
for i=2,50,1 do
	table_of_EFI1[i]=(2/(13+1))*((1-active_right_screen:C(active_right_screen:Size()-50+i-1)/active_right_screen:C(active_right_screen:Size()-50+i))*active_right_screen:V(active_right_screen:Size()-50+i))+(1-(2/(13+1)))*table_of_EFI1[i-1]
end
		

Money=getPortfolioInfoEx('MC0139600000','OPEN51085',2).portfolio_value


Quant=math.floor((Money/4)/active_middle_screen:C(active_middle_screen:Size())/ab)
		
price_step=nil
price_step=PRICE_STEP()


stakan=getQuoteLevel2("TQBR",ACTIVE)
if stakan~=nil then
	offer_price=stakan.offer[1].price-math.fmod(stakan.offer[1].price,price_step)
	bid_price=stakan.bid[10].price-math.fmod(stakan.bid[10].price,price_step)
end

stakan1=getQuoteLevel2("TQBR",ACTIVE)
function OnQuote(class,sec)
	if class =="TQBR" and sec == ACTIVE then
		Offer=stakan.offer[1].price-math.fmod(stakan.offer[1].price,price_step)
		Bid=stakan.bid[1].price-math.fmod(stakan.bid[1].price,price_step)
	end
end

fast_MA_left, slow_MA_left, close_left, aver_deviation_left = MA_function(active_left_screen)
fast_MA_middle, slow_MA_middle, close_middle, aver_deviation_middle = MA_function(active_middle_screen)
fast_MA_right, slow_MA_right, close_right, aver_deviation_right = MA_function(active_right_screen)

quant_for_sell= math.floor((100/(aver_deviation_middle)) / ab)

quant_for_buy = math.floor((100/(aver_deviation_middle)) / ab)
--quant_for_buy=math.floor(25000/((offer_price+price_step)*ab))

o=nil
o=ACTIVE
function fn(sec_code,flags)
    if sec_code==o and bit.band(flags,1)==1 then
        return true
    else return false
    end
end

function DEPO_LIMITS()
    local t=nil
    local hold=nil
	for i=0,getNumberOf("depo_limits")-1 do
		t=getItem("depo_limits",i)
		if t.sec_code==ACTIVE then
		    hold=t.currentbal
		end
	end
    return hold
end

k=nil
k=SearchItems("orders",0,getNumberOf("orders")-1,fn,"sec_code,flags")
	
	
function Trans(operation, price, quantity)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TYPE="L",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=tostring(ACTIVE),
        ACTION="NEW_ORDER",
        OPERATION=operation,
        PRICE=tostring(price),
        QUANTITY=tostring(quantity),
        }
	return Transaction
end

function StopTrans(operation, stopprice, quantity, price, stopprice2)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TYPE="L",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=tostring(ACTIVE),
        ACTION="NEW_STOP_ORDER",
        OPERATION=operation,
        STOPPRICE=tostring(stopprice),
        QUANTITY=tostring(quantity),
        PRICE=tostring(price),
        STOP_ORDER_KIND="TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
        EXPIRY_DATE="GTC",
        OFFSET=tostring(price_step),
        OFFSET_UNITS="PRICE_UNITS",
        SPREAD=tostring(10*price_step),
        SPREAD_UNITS="PRICE_UNITS",
        MARKET_TAKE_PROFIT="NO",
        STOPPRICE2=tostring(stopprice2),
        IS_ACTIVE_IN_TIME="NO",
        MARKET_STOP_LIMIT="NO"
        }
    return Transaction
end

function KillTrans(action, quantity, order_id)
    local Transaction = {
		ACCOUNT="L01-00000F00",
		CLIENT_CODE="OPEN51085",
		TRANS_ID=tostring(os.time()),
		CLASSCODE="TQBR",
		SECCODE=ACTIVE,
		ACTION=action,
		TYPE="L",
		QUANTITY=tostring(quantity),
		ORDER_KEY=tostring(order_id),
		}
	return Transaction
end

function KillStopTrans(action, quantity, stop_order_key)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=ACTIVE,
        ACTION=action,
        TYPE="L",
        QUANTITY=tostring(quantity),
        STOP_ORDER_KEY=tostring(stop_order_key),
        STOP_ORDER_KIND="SIMPLE_STOP_ORDER"
        }
	return Transaction
end


if (MaximumPrice[200] - MinimumPrice[200]) < 0.5 * aver_volatility
 --and math.abs(close_left - fast_MA_left) >= 3.5 * aver_deviation_left
 and math.abs(close_middle - fast_MA_middle) >= 4 * aver_deviation_middle
 and math.abs(close_right - fast_MA_right) >= 4 * aver_deviation_right then
  if fast_MA_middle < slow_MA_middle
    and close_middle < fast_MA_middle
    and k==nil and (DEPO_LIMITS()==0 or DEPO_LIMITS()==nil) then
      sendTransaction(Trans("B", offer_price+2*price_step, quant_for_buy))
	  sleep(2000)
  elseif fast_MA_middle > slow_MA_middle
    and close_middle > fast_MA_middle
    and k==nil and (DEPO_LIMITS()==0 or DEPO_LIMITS()==nil) and SEC_NO_SHORT~=true then
      sendTransaction(Trans("S", bid_price-2*price_step, quant_for_sell))
		  if trans_Status==6 then
			  SEC_NO_SHORT=true
		  end
	  sleep(2000)
  end
end

if table_of_buyed[number]==ACTIVE and izm_lim_ACTIVE==ACTIVE and STOP_NUMBER()==nil and DEPO_LIMITS()>0--[[izm_lim_bal>0]] then 
    sendTransaction(StopTrans("S", 
	    active_middle_screen:C(active_middle_screen:Size())+(2 * aver_deviation_middle-math.fmod(2 * aver_deviation_middle,price_step)), 
	    quant_for_buy, bid_price-2*price_step, active_middle_screen:C(active_middle_screen:Size())-(aver_deviation_middle-math.fmod(aver_deviation_middle,price_step)))) 
	table.remove(table_of_buyed,number)
	sleep(1000)
elseif table_of_selled[number]==ACTIVE and izm_lim_ACTIVE==ACTIVE and STOP_NUMBER()==nil and DEPO_LIMITS()<0--[[izm_lim_bal>0]] then 
    sendTransaction(StopTrans("B", 
	    active_middle_screen:C(active_middle_screen:Size())-(2 * aver_deviation_middle-math.fmod(2 * aver_deviation_middle,price_step)), 
		quant_for_sell, offer_price+2*price_step, active_middle_screen:C(active_middle_screen:Size())+(aver_deviation_middle-math.fmod(aver_deviation_middle,price_step)))) 
    table.remove(table_of_selled,number)
	sleep(1000)
end

if DEPO_LIMITS()==0 and STOP_NUMBER()~=0 then
    sendTransaction(KillStopTrans("KILL_STOP_ORDER", QUANT_OF_STOP(), KILL()))
end


if (STOP_NUMBER()==0 or STOP_NUMBER()==nil)  
  and (ORDERS_NUMBER()~=0 or ORDERS_NUMBER()~=nil)
  and DEPO_LIMITS()<0 then
	repeat
		sendTransaction(KillTrans("KILL_ORDER", math.abs(DEPO_LIMITS()), ORDER_ID()))
		sleep(200)
			if trans_Status==3
				then
					stakan1=getQuoteLevel2("TQBR",ACTIVE)
						if stakan1~=nil then
							offer_price1=stakan1.offer[1].price-math.fmod(stakan1.offer[1].price,price_step)
							bid_price1=stakan1.bid[10].price-math.fmod(stakan1.bid[10].price,price_step)
						end
					sendTransaction(Trans("B", offer_price1+price_step, math.abs(DEPO_LIMITS()/ab)))
					sleep(2000)
					if DEPO_LIMITS()>=0 then
					    break
					end
			else
				sleep(500)
			end
	until DEPO_LIMITS()==0
elseif (STOP_NUMBER()==0 or STOP_NUMBER()==nil)  
  and (ORDERS_NUMBER()~=0 or ORDERS_NUMBER()~=nil)
  and (DEPO_LIMITS()>0)  then
	repeat
		sendTransaction(KillTrans("KILL_ORDER", math.abs(DEPO_LIMITS()), ORDER_ID()))
		sleep(200)
			if trans_Status==3
				then
					stakan2=getQuoteLevel2("TQBR",ACTIVE)
						if stakan2~=nil then
							offer_price2=stakan2.offer[1].price-math.fmod(stakan2.offer[1].price,price_step)
							bid_price2=stakan2.bid[10].price-math.fmod(stakan2.bid[10].price,price_step)
						end
					sendTransaction(Trans("S", bid_price2-price_step, math.abs(DEPO_LIMITS()/ab)))
					sleep(2000)
					if DEPO_LIMITS()<=0 then
					    break
					end
			else
				sleep(500)
			end
	until DEPO_LIMITS()==0
end


if (RSI_function(active_right_screen) <= 20 
  or stochastic_function(active_right_screen)<=0.20)
  and ORDERS_NUMBER() == nil and DEPO_LIMITS() < 0 then
    sendTransaction(Trans("B", offer_price+price_step, math.abs(DEPO_LIMITS()/ab)))
	while ORDERS_NUMBER() ~= nil do
	    sleep(100)
	end
elseif (RSI_function(active_right_screen) >= 80
  or stochastic_function(active_right_screen)>=0.80)
  and ORDERS_NUMBER() == nil and DEPO_LIMITS() > 0 then
    sendTransaction(Trans("S", bid_price-price_step, math.abs(DEPO_LIMITS()/ab)))
	while ORDERS_NUMBER() ~= nil do
	    sleep(100)
	end
end

--message(tostring(ACTIVE))
--sendTransaction(Trans("B", offer_price+2*price_step, quant_for_buy))
sleep(500)
   end
   
   
     
end

IsRun = true
Connected = true
 
function main()
   while IsRun do
        while Connected == false do
		    sleep(100)
			if Connected == true then
			    sleep(5000)
				break
			end
		end
		DATA("MGNT",5)
		DATA("TATN",5)
		DATA("SBERP",5)
		--DATA("MTLR",5)
		DATA("ALRS",5)
		DATA("SBER",5)
		DATA("MOEX",5)
		DATA("HYDR",5)
		DATA("ROSN",5)
		DATA("LKOH",5)
		DATA("SIBN",5)
		DATA("GMKN",5)
		DATA("RTKM",5)
		DATA("SNGS",5)
		DATA("SNGSP",5)
		DATA("CHMF",5)
		--DATA("VTBR",5)
		DATA("NVTK",5)
		DATA("GAZP",5)
		--DATA("MSNG",5)
		DATA("MTSS",5)
		DATA("YNDX",5)
		--[[
		DATA("AFKS",5)
		DATA("AFLT",5)
		DATA("AKRN",5)
		DATA("ALBK",5)
		DATA("ALNU",5)
		DATA("AMEZ",5)
		DATA("APTK",5)
		DATA("AQUA",5)
		DATA("ARSA",5)
		DATA("ASSB",5)
		DATA("AVAN",5)
		DATA("AVAZ",5)
		DATA("BANE",5)
		DATA("BELU",5)
		DATA("BISV",5)
		DATA("BLNG",5)
		DATA("BRZL",5)
		DATA("BSPB",5)
		DATA("CBOM",5)
		DATA("CHEP",5)
		DATA("CHGZ",5)
		DATA("CHKZ",5)
		DATA("CHMK",5)
		DATA("CHZN",5)
		DATA("CLSB",5)
		DATA("CNTL",5)
		DATA("DASB",5)
		DATA("DIOD",5)
		DATA("DSKY",5)
		DATA("DVEC",5)
		DATA("DZRD",5)
		DATA("ELTZ",5)
		DATA("ENRU",5)
		DATA("FEES",5)
		DATA("FESH",5)
		DATA("FTRE",5)
		DATA("GAZA",5)
		DATA("GAZC",5)
		DATA("GAZS",5)
		DATA("GAZT",5)
		DATA("GCHE",5)
		DATA("GRNT",5)
		DATA("GTRK",5)
		DATA("GTSS",5)
		DATA("HALS",5)
		DATA("HIMC",5)
		DATA("IDVP",5)
		DATA("IGST",5)
		DATA("IRAO",5)
		DATA("IRGZ",5)
		DATA("IRKT",5)
		DATA("ISKJ",5)
		DATA("JNOS",5)
		DATA("KAZT",5)
		DATA("KBSB",5)
		DATA("KBTK",5)
		DATA("KCHE",5)
		DATA("KGKC",5)
		DATA("KLSB",5)
		DATA("KMAZ",5)
		DATA("KMEZ",5)
		DATA("KMTZ",5)
		DATA("KOGK",5)
		DATA("KRKN",5)
		DATA("KRKO",5)
		DATA("KROT",5)
		DATA("KRSB",5)
		DATA("KSGR",5)
		DATA("KTSB",5)
		DATA("KUBE",5)
		DATA("KUNF",5)
		DATA("KUZB",5)
		DATA("KZMS",5)
		DATA("KZOS",5)
		DATA("LIFE",5)
		DATA("LNZL",5)
		DATA("LPSB",5)
		DATA("LSNG",5)
		DATA("LSRG",5)
		DATA("LVHK",5)
		DATA("MAGE",5)
		DATA("MAGN",5)
		DATA("MERF",5)
		DATA("MFGS",5)
		DATA("MFON",5)
		DATA("MGNZ",5)
		DATA("MGTS",5)
		DATA("MISB",5)
		DATA("MNFD",5)
		DATA("MOBB",5)
		DATA("MORI",5)
		]]
   end
end
 
function OnDisconnected()
    Connected = false 
end

function OnConnected()
    Connected = true
end
 
function OnStop()
  CSV = io.open(getScriptPath().."/MyTrades.csv", "a+");
  local Position = CSV:seek("end",0);
  if Position == 0 then
    -- Создает строку с заголовками столбцов
	local Header = "Date;Direction;Time opened;Time closed;Sec;Quantity;Price opened;Price closed;Result\n"
	-- Добавляет строку заголовков в файл
	CSV:write(Header);
	-- Сохраняет изменения в файле
	CSV:flush();
  end;
  
  --local bumaga = table_of_trades[trade.sec_code].security
  for k, v in pairs(table_of_trades) do
    --message(k)
	sleep(2000)
    --[[local line = tostring(table_of_trades[k].date_open)..";"..
	           tostring(table_of_trades[k].direction)..";"..
	           tostring(table_of_trades[k].time_opened)..";"..
			   tostring(table_of_trades[k].time_closed)..";"..
			   tostring(table_of_trades[k].security)..";"..
			   tostring(table_of_trades[k].quant_2 / 3)..";"..
			   tostring(table_of_trades[k].price_opened)..";"..
			   tostring(table_of_trades[k].price_closed)..";"..
			   tostring(table_of_trades[k].result / 3).."\n"

    CSV:write(line)
	table_of_trades[k] = nil]]
  end

  CSV:close();
   IsRun = false
end