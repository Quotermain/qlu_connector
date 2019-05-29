function trans(asset, operation, price, quantity)
    local Transaction = {
        ACCOUNT="L01-00000F00",
        CLIENT_CODE="OPEN51085",
        TYPE="L",
        TRANS_ID=tostring(os.time()),
        CLASSCODE="TQBR",
        SECCODE=tostring(asset),
        ACTION="NEW_ORDER",
        OPERATION=operation,
        PRICE=tostring(price),
        QUANTITY=tostring(quantity),
        }
	return Transaction
end