require 'utils/get_depo_limits'
require 'utils/get_stop_orders'

depo_limits = {}
stop_orders = {}

function OnInit()

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
        message(key..' нет среди стопов')
      end
    end
		sleep(10000)
	end
end
