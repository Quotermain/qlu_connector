require('w32')
local dir = 'C:\\Users\\Quotermain233\\Desktop\\VBShared'
local dir2 = dir .. '\\ALRS\\1_ALRS.csv'
message(tostring(w32.ReadFile(dir..dir2)))
--[[local LAST_WRITE,FILE_NAME =
        w32.FILE_NOTIFY_CHANGE_LAST_WRITE,
        w32.FILE_NOTIFY_CHANGE_FILE_NAME

ok,err = w32.watch_for_file_changes(dir,LAST_WRITE+FILE_NAME,TRUE,message)
if not ok then return message(err) end
ok,err = w32.watch_for_file_changes(dir2,LAST_WRITE+FILE_NAME,TRUE,message)
if not ok then return message(err) end

winapi.sleep(-1)]]