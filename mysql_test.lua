require "luasql.mysql"

env = luasql.mysql()
conn = assert(
	env:connect(
		"news", "Quotermain233", 
		"Quotermain233", "192.168.0.105", 
		3306
	)
)

cur = assert(
		conn:execute(
			string.format(
				[[SELECT * FROM Apple]], 
				asset
			)
		)
	)
row = cur:fetch({}, 'a')

message(row.id)