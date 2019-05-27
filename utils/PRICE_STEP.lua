function PRICE_STEP(ACTIVE)
    t=nil
	for i=0,getNumberOf("securities")-1 do
		t=getItem("securities",i)
			if t.code==ACTIVE then
				limit=t.min_price_step 
			end
	end
	return limit
end