function depo_limits(asset)
    local t = nil
    local hold = nil
	local price = nil
	for i=0,getNumberOf("depo_limits")-1 do
		t=getItem("depo_limits",i)
		if t.sec_code==asset then
		    hold = t.currentbal
			price = t.wa_position_price
		end
	end
    return hold, price
end
