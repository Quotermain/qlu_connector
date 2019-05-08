function number_of_stops(seccode)
	local t=nil
	local stop_number=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==seccode and bit.band(t.flags,1)>0 then
			stop_number=t.qty
		end
	end
	return stop_number
end

function id_of_stop_to_kill(seccode)
    local t=nil
    local kill=nil
	for i=0,getNumberOf("stop_orders")-1 do
		t=getItem("stop_orders",i)
		if t.sec_code==seccode and bit.band(t.flags,1)==0x1 then
		    kill=t.order_num
		end
	end
    return kill
end

function kill_stop(seccode, quantity, stop_order_key)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=seccode,
        ACTION="KILL_STOP_ORDER",
        TYPE="L",
        QUANTITY=tostring(quantity),
        STOP_ORDER_KEY=tostring(stop_order_key),
        STOP_ORDER_KIND="SIMPLE_STOP_ORDER"
        }
	return Transaction
end

function send_stop(operation, stopprice, quantity, price, stopprice2, seccode, price_step)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TYPE="L",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=tostring(seccode),
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

--Надо одну стоп заявку. Посылает две.
function OnOrder(order)
	if (number_of_stops('HYDR')==0 or number_of_stops('HYDR')==nil) then
		if bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 then
			if bit.band(order.flags,4)>1 then
				sendTransaction(
					send_stop(
						'B', 0.535, order.qty, 0.535, 0.5410, order.sec_code, 0.01
					)
				)
				--message('Sell')
			elseif bit.band(order.flags,4)==0 then
				sendTransaction(
					send_stop(
						'S', 0.5410, order.qty, 0.5410, 0.535, order.sec_code, 0.01
					)
				)
				--message('Buy')
			end
		end
	end
end

function number_of_items(t)
	if t.sec_code == 'HYDR' and bit.band(t.flags,1)>0 then
		return true
	else 
		return false
	end
end

function main()	
    while true do
		message(tostring(id_of_stop_to_kill('HYDR'))) --раз в секунду выводит текущие дату и время
		--[[sendTransaction(kill_stop(
			'HYDR', number_of_stops("HYDR"), id_of_stop_to_kill('HYDR')
		))]]
		t1 = SearchItems("stop_orders", 0, getNumberOf("stop_orders")-1, number_of_items)

		sleep(1000)
		message(tostring(#t1))
		sleep(10000)
		
	end
end