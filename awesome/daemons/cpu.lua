-- Outputs
-- daemon::cpu
--      CPU temp

local awful = require("awful")
local helpers = require("helpers")

-- Commands
local update_interval = 15
local temp_file = "tmp/awesome-evil-cpu"

-- TODO find a way to triple quote?? and non external bash script
local cpu_script = [[
    bash /home/fried-milk/.config/awesome/daemons/cpu-test
]]

helpers.remote_watch(cpu_script, update_interval, temp_file, function(stdout)
    local temperature = string.sub(stdout, 2, 8)
    local usage = string.sub(stdout, 12, 20)
    awful.spawn.with_shell("rm"..temp_file)
    awesome.emit_signal("daemon::cpu", temperature, usage)
end)

