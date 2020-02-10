require "luasql.mysql"

env = luasql.mysql()
conn = assert(env:connect("trading_data", "Quotermain233", "Quotermain233", "192.168.0.105", 3306))

assets = {
		"MGNT",
		"TATN",
		"SBERP",
		"MTLR",
		"ALRS",
		"SBER",
		"MOEX",
		"HYDR",
		"ROSN",
		"LKOH",
		"SIBN",
		"GMKN",
		"RTKM",
		"SNGS",
		"SNGSP",
		"CHMF",
		--"VTBR",
		"NVTK",
		"GAZP",
		--"MSNG",
		"MTSS",
		"YNDX"
}

--[[
res = assert(
	conn:execute(
		"CREATE TABLE IF NOT EXISTS depo_limits(asset TEXT, limits INT)"
	)
)

for i = 1, #assets do
	res = assert(
		conn:execute(
			string.format(
				"INSERT INTO depo_limits (asset) VALUES('%s')", assets[i])
		)
	)
end
]]
IsRun = true

function main ()
	while IsRun do
		for j = 1, #assets do
			for i=0,getNumberOf("depo_limits")-1 do
				t=getItem("depo_limits",i)
				if t.sec_code == assets[j] then
					res = assert(
						conn:execute(
							string.format(
								[[UPDATE depo_limits SET limits = '%s' WHERE asset = '%s']], 
								t.currentbal, 
								assets[j]
							)
						)
					)
				end
			end
		end
	end
end

function OnStop()
	IsRun = false
end