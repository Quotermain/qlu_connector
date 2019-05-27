function getLotSizeBySecCode(ACTIVE)
   local status = getParamEx("TQBR", ACTIVE, "lotsize"); -- Беру размер лота для кода класса "TQBR"
   return math.ceil(status.param_value);                   -- Отбрасываю ноли после запятой
end;