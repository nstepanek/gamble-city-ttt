
gcs = "GAMBLE CITY: "


function sqlMoneyStat(ply, steamID)
	local id = sql.QueryValue("SELECT id FROM player_money WHERE id = '"..steamID.."'")
	local money = tonumber(sql.QueryValue("SELECT money FROM player_money WHERE id = '"..steamID.."'"))
	local win_count = sql.QueryValue("SELECT win_count FROM player_money WHERE id = '"..steamID.."'")
	local date_joined = sql.QueryValue("SELECT date_joined FROM player_money WHERE id = '"..steamID.."'")
	local last_used_name = sql.QueryValue("SELECT last_used_name FROM player_money WHERE id = '"..steamID.."'")
	ply:SetNWString("id", id)
	ply:SetNWInt("money", money)
	ply:SetNWInt("win_count", win_count)
	--Msg(gcs .. "Loaded player data, ID: " .. id .. " Money: " .. tostring(money) .. " Win Count: " .. 
	--	tostring(win_count) .. " Date Joined: " .. date_joined .. "\n")
end

function save(ply)
	id = ply:GetNWString ("steamID")
	local money = ply:GetNWInt("money")
	win_count = ply:GetNWInt("win_count")
	name = ply:Name()

	sql.Query("UPDATE player_money SET money = " .. money .. ", win_count = " .. win_count .. ", last_used_name = '" .. name .. "' WHERE id = '" .. id .. "'")
	ply:PrintMessage(2, "Gamble City stats updated.")
end

function tableExists()
	--sql.Query("DROP TABLE player_money")
	if sql.TableExists("player_money")then
		Msg(gcs .. "Table already exists.\n")
	else
		if (!sql.TableExists("player_money")) then
			query = "CREATE TABLE player_money (id varchar(255) unique, money unsigned big int, win_count int, date_joined DATE DEFAULT (datetime('now', 'localtime')), last_used_name varchar(255))"
			result = sql.Query(query)
			if (sql.TableExists("player_money")) then
				Msg(gcs .. "Money table created.\n")
			else
				Msg(gcs .. "Money table creation failed!\n")
				Msg(sql.LastError(result) .. "\n")
			end
		end
	end
end

function newPlayer(steamID, ply)
	local name = ply:Name()
	sql.Query("INSERT INTO player_money (id, money, win_count, last_used_name) VALUES ('" .. steamID .."', '100', '0', '" .. name .. "')")
	result = sql.Query("SELECT id, money, win_count FROM player_money WHERE id = '" .. steamID .. "'")
	
	if (result) then
		Msg(gcs .. "Player account created.\n")
		sqlMoneyStat(ply, steamID)
	else
		Msg(gcs .. "Something went wrong with account creation!\n")
	end
end

function giveMoney(ply, money)
	curMoney = ply:GetNWInt("money")
	newMoney = curMoney + money
	ply:SetNWInt("money", newMoney)
	ply:ChatPrint("You have been given $10.")
end


--[[-----------------
		HOOKS		-
--]]-----------------

function playerExists(ply)
	local steamID = ply:GetNWString("steamID")
	result = sql.Query("SELECT id, money, win_count, date_joined FROM player_money WHERE id = '" .. steamID .. "'")
	
	if (result) then
		sqlMoneyStat(ply, steamID)
	else
		newPlayer(steamID, ply)
	end
end

function initialize()
	tableExists()
end

function playerInitialSpawn(ply)
	timer.Create("Steam_id_delay", 1, 1, 
		function()
			local steamID = ply:SteamID()
			ply:SetNWString("steamID", steamID)
			playerExists(ply)
			timer.Create("SaveStat" .. steamID, 60, 0, function() save(ply) end)
			--timer.Create("GiveMoney" .. steamID, 180, 0, function() giveMoney(ply, 10) end)
		end
	)
	buildPlayers()
end

function checkMoney(ply, text, team)
	text = string.lower(text)
	
	if (text == "!money") then
		local money = ply:GetNWInt("money")
		ply:ChatPrint("$" .. tostring(money))
		
		return ""
	end
end

function resetMoney(ply, text, team)
	local money = ply:GetNWInt("money")
	text = string.lower(text)
	
	if (text == "!resetmoney") then
		if (money < 25) then
			ply:SetNWInt("money", 25)
			ply:ChatPrint("Money reset to 25.")
		else
			ply:ChatPrint("You are too rich to reset.")
		end
	
		return ""
	end
end

function onDisconnect(ply)
	save(ply)
	steamID = ply:GetNWString("steamID")
	timer.Remove("SaveStat" .. steamID)
	timer.Remove("GiveMoney" .. steamID)
end

function gcInfo(ply, text, team)
	text = string.lower(text)

	if text == "!gc" or text == "!gamblecity" then
		ply:ChatPrint("Gamble City awards players money to be used for various purposes. To see commands use !gchelp, for a list of games use !gcgames.")
		return ""
	end
end

function help(ply, text, team)
	text = string.lower(text)

	if text == "!gchelp" then
		ply:ChatPrint("!money   - View your money.")
		ply:ChatPrint("!gcgames - View available games.")
		return ""
	end
end

function games(ply, text, team)
	text = string.lower(text)

	if text == "!gcgames" then
		ply:ChatPrint("!cointoss [wager] [heads/tails]")
		return ""
	end
end

function getMoneyInfo(ply, text, team)
	text = string.lower(text)
	steamID = ply:GetNWString("steamID")
	
	if text == "!getmoneyinfo" then
		save(ply)
		local result = sql.Query("SELECT * FROM player_money WHERE id = '" .. steamID .. "'")
		for k, v in ipairs(result) do
			ply:ChatPrint(table.tostring(v))
		end
		return ""
	end
end

function printAllMoneyStats(ply, text, team)
	text = string.lower(text)
	
	if text == "!allmoneystats" then
		print("got here")
		local result = sql.Query("SELECT money, last_used_name FROM player_money")
		for k, v in ipairs(result) do
			ply:PrintMessage(2, v["last_used_name"] .. ": " .. v["money"])
		end
		return ""
	end
end

hook.Add("Initialize", "Initialize", initialize)
hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn", playerInitialSpawn)
hook.Add("PlayerSay", "CheckMoney", checkMoney)
hook.Add("PlayerSay", "ResetMoney", resetMoney)
hook.Add("PlayerDisconnected", "OnDisconnect", onDisconnect)
hook.Add("PlayerSay", "GCInfo", gcInfo)
hook.Add("PlayerSay", "Help", help)
hook.Add("PlayerSay", "Games", games)
hook.Add("PlayerSay", "GetMoneyInfo", getMoneyInfo)
hook.Add("PlayerSay", "PrintAllMoneyStats", printAllMoneyStats)





print("$ gc.lua                  $")








