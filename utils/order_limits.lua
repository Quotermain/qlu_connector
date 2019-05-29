function order_limits(asset)
    local t = nil
    local hold = nil
	for i=0,getNumberOf("orders")-1 do
		t=getItem("orders",i)
		if t.sec_code==asset and bit.band(t.flags,1)>1 then
		    hold = t.qty
		end
	end
    return hold
end