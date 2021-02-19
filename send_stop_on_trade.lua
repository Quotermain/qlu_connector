require 'get_distances_to_stop'
require 'utils/get_depo_limits'
require 'utils/get_stop_orders'
require 'utils/string_split'

dist_to_stop = {}
depo_limits = {}
stop_orders = {}

function OnStopOrder(stops)
  --[[При получении новой стоп-заявки обновляет таблицу стоп-заявок скрипта]]
  get_stop_orders()
end

function OnDepoLimit(depos)
  --[[При изменении позиций по инструментам обновляет таблицу активов скрипта]]
  get_depo_limits()
end

function OnInit()
  --[[Переносим из файла в массив допустимый процент потерь для расчета
  стоп-лосса и тейк-профита]]
  get_distances_to_stop()

  --[[Итерируемся по таблице "Лимиты по бумагам" и добавляем в массив
  только ненулевые позиции по Т0]]
  get_depo_limits()

  --[[Итерируемся по таблице стопов и добавляем в массив только активные]]
  get_stop_orders()

end

function main()
	while true do
    --[[Итерируемся по массиву активов и проверяем, есть ли имеющиеся активы
    в списке стопов]]
    for key, value in pairs(depo_limits) do
      if stop_orders[key] == nil then
        message(key..' not in stops'..' '..value['bal'])
      end
    end
		sleep(10000)
	end
end
