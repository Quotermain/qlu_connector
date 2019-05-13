function OnInit()
	function Run(asset, period)
		--CSV = io.open("C:/Users/Quotermain233/Desktop/VBShared/"..asset.."/"..tostring(period).."_"..asset..".csv", "r")
		file = "C:/Users/Quotermain233/Desktop/VBShared/"..asset.."/"..tostring(period).."_"..asset..".csv"
		lines_of_file = {}
		for line in io.lines(file) do
			lines_of_file[#lines_of_file + 1] = line
		end
		message(tostring(lines_of_file[#lines_of_file]))
		sleep(2000)
	end
end

IsRun = true

function main()
	while IsRun do
		Run('ALRS', 1)
	end
end

function OnStop()
	IsRun = false
end

--CSV1 = io.open("C:/Users/Quotermain233/Desktop/VBShared/test.csv", "a+");
--CSV1:write('Hello \n')
--CSV1:flush()


 


 
