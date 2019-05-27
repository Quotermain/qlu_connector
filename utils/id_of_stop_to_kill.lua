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