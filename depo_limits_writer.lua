IsRun = true

function main ()
	while IsRun do
		CSV1 = io.open("C:/Users/Quotermain233/Desktop/VBShared/test/depo_limits.csv", "w+")
		for i=0,getNumberOf("depo_limits")-1 do
			t=getItem("depo_limits",i)
			local line = tostring(t.sec_code)..','..tostring(t.currentbal)..'\n'
			CSV1:write(line)
		end
		CSV1:flush()
		--message('done')
		sleep(300)
	end
end

function OnStop()
	IsRun = false
	CSV1:close()
end