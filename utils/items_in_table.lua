function items_in_table(t)
	if t.sec_code == 'ALRS' and bit.band(t.flags,1)>0 then
		return true
	else 
		return false
	end
end