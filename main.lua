function quantity_in_stop(seccode)
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

function killstop_trans(seccode, quantity, stop_order_key)
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

function stop_trans(operation, stopprice, quantity, price, stopprice2, seccode, price_step)
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
	if (quantity_in_stop('HYDR')==0 or quantity_in_stop('HYDR')==nil) then
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

function items_in_table(t)
	if t.sec_code == 'HYDR' and bit.band(t.flags,1)>0 then
		return true
	else 
		return false
	end
end

function string:split(sSeparator, nMax, bRegexp)
    if sSeparator == '' then
        sSeparator = ','
    end

    if nMax and nMax < 1 then
        nMax = nil
    end

    local aRecord = {}

    if self:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1

        local nField, nStart = 1, 1
        local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = self:sub(nStart, nFirst-1)
            nField = nField+1
            nStart = nLast+1
            nFirst,nLast = self:find(sSeparator, nStart, bPlain)
            nMax = nMax-1
        end
        aRecord[nField] = self:sub(nStart)
    end

    return aRecord
end

function read_from_file(path, sep, tonum, null)
    tonum = tonum or true
    sep = sep or ','
    null = null or ''
    local csvFile = {}
    local file = assert(io.open(path, "r"))
    for line in file:lines() do
        fields = line:split(sep)
        if tonum then -- convert numeric fields to numbers
            for i=1,#fields do
                local field = fields[i]
                if field == '' then
                    field = null
                end
                fields[i] = tonumber(field) or field
            end
        end
        table.insert(csvFile, fields)
    end
    file:close()
    return csvFile
end

data_path = 'C:/Users/Quotermain233/Desktop/VBShared/test/'

function main()	
    while true do
	
		stop_items = SearchItems("stop_orders", 0, getNumberOf("stop_orders")-1, items_in_table)
		if stop_items ~= nil and #stop_items>1 then
			sendTransaction(
				killstop_trans(
					'HYDR', quantity_in_stop("HYDR"), id_of_stop_to_kill('HYDR')
				)
			)
		end
		
		signal = read_from_file(data_path..'/HYDR/signal.csv')
		
		message(tostring(signal[1][3]))
		
		sleep(10000)
		
	end
end