require 'utils/get_distances_to_stop'
require 'utils/get_depo_limits'
require 'utils/get_stop_orders'
require 'utils/string_split'
require 'utils/stop_trans'

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
        message(
          key..' not in stops. Balance: '..tostring(value['bal'])..
          '. Price step: '..tostring(value['price_step'])..'. Lot size: '..
          tostring(value['lot_size'])..'. Position price: '..
          tostring(value['position_price'])
        )

        if value['bal'] < 0 then
          stop_limit_price = (
            value['position_price'] + dist_to_stop[key] * value['position_price']
          )
    			stop_limit_price = (
            stop_limit_price - math.fmod(stop_limit_price, value['price_step'])
          )
    			take_profit_price = (
            value['position_price'] - dist_to_stop[key] * value['position_price']
          )
    			take_profit_price = (
            take_profit_price - math.fmod(take_profit_price, value['price_step'])
          )
    			sendTransaction(
    				stop_trans(
    					'B', take_profit_pricet,
    					math.abs(limits) / lot_size,
    					stop_limit_price + 10 * price_step,
    					stop_limit_price,
    					asset, price_step
    				)
    			)
        elseif value['bal'] > 0 then
          stop_limit_price = (
            value['position_price'] - dist_to_stop[key] * value['position_price']
          )
    			stop_limit_price = (
            stop_limit_price - math.fmod(stop_limit_price, value['price_step'])
          )
    			take_profit_price = (
            value['position_price'] + dist_to_stop[key] * value['position_price']
          )
    			take_profit_price = (
            take_profit_price - math.fmod(take_profit_price, value['price_step'])
          )
          sendTransaction(
    				stop_trans(
    					'S', take_profit_price,
    					math.abs(limits) / lot_size,
    					stop_limit_price - 10 * price_step,
    					stop_limit_price,
    					asset, price_step
    				)
    			)
        end

      end
    end
		sleep(10000)
	end
end
