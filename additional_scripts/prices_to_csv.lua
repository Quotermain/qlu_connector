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

--Один раз загрузить много свечей по различным таймфреймам для расчета индикаторов
--Один раз в питоновском скрипте выгрузить свечи в датафрейм
--В файлы-буфферы (по одному для каждого актива) в цикле подгружать свежие данные по ценам и объему для предсказаний.
 
--file = "C:/Users/Quotermain233/Desktop/VBShared/"..asset.."/"..tostring(period).."_"..asset..".csv"
file = "C:/Users/Quotermain233/Desktop/VBShared/ALRS/2_ALRS.csv"
lines_of_file = {}
for line in io.lines(file) do
	lines_of_file[#lines_of_file + 1] = line
end
last_line = lines_of_file[#lines_of_file]
file = io.open(file, 'w+')

function OnInit()
	function Run(asset, period)
		ds1 = CreateDataSource('TQBR', asset, INTERVAL_M1)
		ds1:SetEmptyCallback()
	
		local new_line = tostring(ds1:T(ds1:Size()).year..'-'..
									ds1:T(ds1:Size()).month..'-'..
									ds1:T(ds1:Size()).day..' '..
									ds1:T(ds1:Size()).hour..':'..
									ds1:T(ds1:Size()).min..':'..
									ds1:T(ds1:Size()).sec
									)..','..
							tostring(ds1:H(ds1:Size()))..','..
							tostring(ds1:L(ds1:Size()))..','..
							tostring(ds1:O(ds1:Size()))..','..
							tostring(ds1:C(ds1:Size()))..','..
							tostring(ds1:V(ds1:Size()))
		last_line = new_line		
		if split_string(new_line, ',')[0] == split_string(last_line, ',')[0] then
			lines_of_file[#lines_of_file] = last_line
		elseif split_string(new_line, ',')[0] ~= split_string(last_line, ',')[0] then
			table.insert(lines_of_file, last_line)
			table.remove(lines_of_file, 1)
		end
		
		
		for i=1, #lines_of_file do
			file:write(lines_of_file[i]..'\n')
		end
		file:flush()
		--message(new_line)
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
	file:close()
	IsRun = false
end

--CSV1 = io.open("C:/Users/Quotermain233/Desktop/VBShared/test.csv", "a+");
--CSV1:write('Hello \n')
--CSV1:flush()


 


 
