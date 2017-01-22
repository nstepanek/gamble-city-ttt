
--[[
ttt_debug_preventwin 1
ttt_minimum_players 1
ttt_force_terror
ttt_force_traitor
]]--

print("$$$$$$$$$$$$$$$$$$$$$$$$$$$")
print("$                         $")

if SERVER then
	include("../gamble_city/table_utils.lua")
	include("../gamble_city/string_utils.lua")
	include("../gamble_city/gc.lua")
	include("../gamble_city/gc_pay.lua")
	include("../gamble_city/coin_toss.lua")
end

print("$                         $")
print("$$$$$$$$$$$$$$$$$$$$$$$$$$$") 
print("$                         $")
print("$  GAMBLECITY HAS LOADED  $")
print("$                         $")
print("$$$$$$$$$$$$$$$$$$$$$$$$$$$") 
