function get_stop_orders()
  for i=0, getNumberOf('stop_orders') - 1 do
    stop_order = getItem('stop_orders', i)
    ticker = stop_order.sec_code
    if bit.test(stop_order.flags, 0) == true then
      stop_orders[ticker] = {['lots']=stop_order.qty}
    end
  end
end
