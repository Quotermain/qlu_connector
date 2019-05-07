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

function StopTrans(operation, stopprice, quantity, price, stopprice2, seccode, price_step)
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

function OnOrder(order)
	if (STOP_NUMBER()==0 or STOP_NUMBER()==nil) then
		if bit.band(order.flags,1)==0 and bit.band(order.flags,2)==0 then
			if bit.band(order.flags,4)>1 then
				sendTransaction(
					StopTrans(
						'B', 0.5380, order.qty, 0.5380, 0.5410, order.sec_code, 0.01
					)
				)
				--message('Sell')
			elseif bit.band(order.flags,4)==0 then
				sendTransaction(
					StopTrans(
						'S', 0.5410, order.qty, 0.5410, 0.5380, order.sec_code, 0.01
					)
				)
				--message('Buy')
			end
		end
	end
end



function main()	
    while true do
		--message('Microphone check') --раз в секунду выводит текущие дату и время		
		--sleep(5000)
	end
end