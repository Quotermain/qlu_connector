file_path = getScriptPath()..'/data/dist_to_stop.csv'

function get_distances_to_stop()
  for line in io.lines(file_path) do
    splited_line = string_split(line)
    dist_to_stop[splited_line[1]] = tonumber(splited_line[2])
  end
end
