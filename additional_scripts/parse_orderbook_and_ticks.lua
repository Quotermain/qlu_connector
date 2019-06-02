require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

res = assert(
	conn:execute(
		string.format(
			[[INSERT INTO test 
			(test1, test2)
			VALUES ('%s', '%s')]],
			1, 2)
	)
)

message(tostring(conn))