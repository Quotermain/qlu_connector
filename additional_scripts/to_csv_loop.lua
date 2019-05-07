Run = true;		-- Флаг поддержания работы скрипта


 
-- Вызывается терминалом QUIK в момент запуска скрипта
timeframes = {
  INTERVAL_TICK, 
  INTERVAL_M1,
  INTERVAL_M2,
  INTERVAL_M3,
  INTERVAL_M4,
  INTERVAL_M5,
  INTERVAL_M6,
  INTERVAL_M10,
  INTERVAL_M15,
  INTERVAL_M20,
  INTERVAL_M30,
  INTERVAL_H1,
  INTERVAL_H2,
  INTERVAL_H4
}
function OnInit()
    function DATA(ACTIVE)
	    
		for i=1, 14 do
			ds1 = CreateDataSource('TQBR', ACTIVE, timeframes[i])
			ds1:SetEmptyCallback()
	
			-- Создает, или открывает для чтения/добавления файл CSV в той же папке, где находится данный скрипт
			CSV1 = io.open("C:/Users/Quotermain233/Desktop/VBShared/"..ACTIVE.."/"..timeframes[i].."_"..ACTIVE..".csv", "w+");

			num_of_bars_left = 5000
			for i = 1, num_of_bars_left do
				local line = tostring(ds1:T(ds1:Size() - num_of_bars_left + i).year..'-'..
									ds1:T(ds1:Size() - num_of_bars_left + i).month..'-'..
									ds1:T(ds1:Size() - num_of_bars_left + i).day..' '..
									ds1:T(ds1:Size() - num_of_bars_left + i).hour..':'..
									ds1:T(ds1:Size() - num_of_bars_left + i).min..':'..
									ds1:T(ds1:Size() - num_of_bars_left + i).sec
									)..','..
							tostring(ds1:H(ds1:Size() - num_of_bars_left + i))..','..
							tostring(ds1:L(ds1:Size() - num_of_bars_left + i))..','..
							tostring(ds1:O(ds1:Size() - num_of_bars_left + i))..','..
							tostring(ds1:C(ds1:Size() - num_of_bars_left + i))..','..
							tostring(ds1:V(ds1:Size() - num_of_bars_left + i))..'\n'
				CSV1:write(line)
			end
			CSV1:flush()
		end
	

    end
end;
 
-- Основная функция скрипта (пока работает она, работает скрипт)
function main()
	    DATA("MGNT")
		DATA("TATN")
		DATA("SBERP")
		DATA("MTLR")
		DATA("ALRS")
		DATA("SBER")
		DATA("MOEX")
		DATA("HYDR")
		DATA("ROSN")
		DATA("LKOH")
		DATA("SIBN")
		DATA("GMKN")
		DATA("RTKM")
		DATA("SNGS")
		DATA("SNGSP")
		DATA("CHMF")
		DATA("NVTK")
		DATA("GAZP")
		DATA("MTSS")
		DATA("YNDX")
		message("Done")
end;
 
-- Вызывается терминалом QUIK в момент остановки скрипта
function OnStop()
	-- Выключает флаг, чтобы остановить цикл while внутри main
	Run = false;
	-- Закрывает открытый CSV-файл 
	CSV1:close();	
	CSV2:close();
	CSV3:close();
end;
 
