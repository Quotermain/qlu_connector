function split_string(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function OnInit()
	function Run(asset, period)
		file = "C:/Users/Quotermain233/Desktop/VBShared/"..asset.."/"..tostring(period).."_"..asset..".csv"
		lines_of_file = {}
		for line in io.lines(file) do
			lines_of_file[#lines_of_file + 1] = line
		end
		last_string = lines_of_file[#lines_of_file]
		message(tostring(split_string(last_string, ',')[3]))
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


 


 
