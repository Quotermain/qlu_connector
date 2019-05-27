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