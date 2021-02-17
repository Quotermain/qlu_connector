function get_depo_limits()
  for i=0, getNumberOf('depo_limits') - 1 do
    asset = getItem('depo_limits', i)
    ticker = asset.sec_code
    bal = asset.currentbal
    if (asset.limit_kind == 0) and (bal ~= 0) then
      depo_limits[ticker] = {['bal']=bal}
    end
  end
end
