IsRun = true

function main ()
	while IsRun do
		CSV1 = io.open("C:/Users/Quotermain233/Desktop/VBShared/test/depo_limits.csv", "w+")
		if CSV1 then 
			for i=0,getNumberOf("depo_limits")-1 do
				t=getItem("depo_limits",i)
				local line = tostring(t.sec_code)..','..tostring(t.currentbal)..'\n'
				CSV1:write(line)
			end
		end
		if CSV1 then
			CSV1:flush()
		end
		--message('done')
		sleep(300)
	end
end

function OnStop()
	IsRun = false
	if CSV1 then
		CSV1:close()
	end
end