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
        SPREAD=tostring(10 * price_step),
        SPREAD_UNITS="PRICE_UNITS",
        MARKET_TAKE_PROFIT="NO",
        STOPPRICE2=tostring(stopprice2),
        IS_ACTIVE_IN_TIME="NO",
        MARKET_STOP_LIMIT="NO"
        }
    return Transaction
end