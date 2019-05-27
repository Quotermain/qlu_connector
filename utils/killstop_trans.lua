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