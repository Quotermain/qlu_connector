function string_split(string)
  splitted = {}
  for word in string.gmatch(string, '([^,]+)') do
    table.insert(splitted, word)
  end
  return splitted
end
