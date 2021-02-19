function get_depo_limits()
  for i=0, getNumberOf('depo_limits') - 1 do
    asset = getItem('depo_limits', i)

    ticker = asset.sec_code
    --Получаем код класса
    if string.find(ticker, 'SPB') ~= nil then
      class = 'SPBXM'
    else
      class = 'TQBR'
    end

    bal = tonumber(asset.currentbal)
    if (asset.limit_kind == 0) and (bal ~= 0) then
      asset_info = getSecurityInfo(class, ticker)
      price_step = tonumber(asset_info.min_price_step)
      lot_size = tonumber(asset_info.lot_size)
      depo_limits[ticker] = {
        ['bal']=bal, ['price_step']=price_step, ['lot_size']=lot_size
      }
    end
  end
end
