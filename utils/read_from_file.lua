function read_from_file(path, sep, tonum, null)
    tonum = tonum or true
    sep = sep or ','
    null = null or ''
    local csvFile = {}
    local file = io.open(path, "r")
	if file then
		for line in file:lines() do
			fields = line:split(sep)
			if tonum then -- convert numeric fields to numbers
				for i=1,#fields do
					local field = fields[i]
					if field == '' then
						field = null
					end
					fields[i] = tonumber(field) or field
				end
			end
			table.insert(csvFile, fields)
		end
		file:close()
		return csvFile
	else 
		return nil
	end
end