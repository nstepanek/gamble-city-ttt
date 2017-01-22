

function sql_value_stats ( ply )
	unique_id = sql.QueryValue("SELECT unique_id FROM player_info WHERE unique_id = '"..steamID.."'")
	money = sql.QueryValue("SELECT money FROM player_info WHERE unique_id = '"..steamID.."'")
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("money", money)
end
 
function sql_value_skills ( ply )
	unique_id = sql.QueryValue("SELECT unique_id FROM player_skills WHERE unique_id = '"..steamID.."'")
	speech = sql.QueryValue("SELECT speech FROM player_skills WHERE unique_id = '"..steamID.."'")
	fish = sql.QueryValue("SELECT fish FROM player_skills WHERE unique_id = '"..steamID.."'")
	farm = sql.QueryValue("SELECT farm FROM player_skills WHERE unique_id = '"..steamID.."'")
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("speech", speech)
	ply:SetNWInt("fish", fish)
	ply:SetNWInt("farm", farm)
end
 
function saveStat ( ply )
	money = ply:GetNWInt("money")
	unique_id = ply:GetNWString ("SteamID")
	speech = ply:GetNWInt("speech")
	fish = ply:GetNWInt("fish")
	farm = ply:GetNWInt("farm")
	sql.Query("UPDATE player_skills SET speech = "..speech..", fish = "..fish..", farm = "..farm.." WHERE unique_id = '"..unique_id.."'")
	sql.Query("UPDATE player_info SET money = "..money.." WHERE unique_id = '"..unique_id.."'")
	ply:ChatPrint("Stats updated !")
end

function tables_exist()
	if sql.TableExists("player_info") && sql.TableExists("player_skills") then
		Msg("Both tables already exist")
	else
		if (!sql.TableExists("player_info")) then
			query = "CREATE TABLE player_info ( unique_id varchar(255), money int )"
			result = sql.Query(query)
			if (sql.TableExists("player_info")) then
				Msg("Success! table 1 created \n")
			else
				Msg("Something went wrong with the player_info query! \n")
				Msg(sql.LastError(result) .. "\n")
			end
		end
		if (!sql.TableExists("player_skills")) then
			query = "CREATE TABLE player_skills ( unique_id varchar(255), speech int, fish int, farm int )"
			result = sql.Query(query)
			if (sql.TableExists("player_skills")) then
				Msg("Success! table 2 created \n")
			else
				Msg("Something went wrong with the player_stats query! \n")
				Msg(sql.LastError(result) .. "\n")
			end
		end
	end
end

function new_player( SteamID, ply )
	steamID = SteamID
	sql.Query( "INSERT INTO player_info (`unique_id`, `money`)VALUES ('"..steamID.."', '100')" )
	result = sql.Query( "SELECT unique_id, money FROM player_info WHERE unique_id = '"..steamID.."'" )
	
	if (result) then
		sql.Query( "INSERT INTO player_skills (`unique_id`, `speech`, `fish`, `farm`)VALUES ('"..steamID.."', '1', '1', '1')" )
		result = sql.Query( "SELECT unique_id, speech, fish, farm FROM player_skills WHERE unique_id = '"..steamID.."'" )
		if (result) then
			Msg("Player account created !\n")
			sql_value_stats( ply )
			sql_value_skills( ply )
		else
			Msg("Something went wrong with creating a players skills !\n")
		end
	else
		Msg("Something went wrong with creating a players info !\n")
	end
end

function player_exists(ply)
	steamID = ply:GetNWString("SteamID")
	result = sql.Query("SELECT unique_id, money FROM player_info WHERE unique_id = '" .. steamID .. "'")
	
	if (result) then
		sql_value_stats(ply)
		sql_value_skills(ply)
	else
		new_player(steamID, ply)
	end
end

function Initialize()
	tables_exist()
end

function PlayerInitialSpawn(ply)
	timer.Create("Steam_id_delay", 1, 1, 
		function()
			SteamID = ply:SteamID()
			ply:SetNWString("SteamID", SteamID)
			timer.Create("SaveStat", 120, 0, function() saveStat(ply) end)
			player_exists(ply)
		end
	)
end

hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn", PlayerInitialSpawn)
hook.Add("Initialize", "Initialize", Initialize)





print("/   gamble_city.lua     /")







function testPay(ply, text, team)
	text = string.lower(text)
	
	if string.starts(text, "!testpay") then
		wordTable = {}
		count = 0
		for word in string.gmatch(text, '([^ ]+)') do
			wordTable[count] = word
			count = count + 1
		end
		PrintMessage(2, tostring(count))
		
		if count == 5 then
			if string.isnumber(wordTable[1]) and string.isnumber(wordTable[2]) and string.isnumber(wordTable[3]) then
				result = WIN_INNOCENT
				if (wordTable[4] == "t") then result = WIN_TRAITOR end
				numTraitors = tonumber(wordTable[1])
				numDetectives = tonumber(wordTable[2])
				numInnocents = tonumber(wordTable[3])
				numGood = numDetectives + numInnocents
				numPlayers = numGood + numTraitors
				
				if pprint then
					message = "GC Pay\nTraitor Count: " .. numTraitors .. "\nDetective Count: " .. numDetectives ..
						"\nInnocent Count: " .. numInnocents .. "\nTotal Count: " .. numPlayers
					PrintMessage(2, message)
				end
				
				tProportion = numTraitors / numPlayers
				dProportion = numDetectives / numPlayers
				iProportion = numInnocents / numPlayers
				moneyPool = playerCounts["total"] * 100 + 300
				traitorPercentage = 0
				detectivePercentage = 0
				innocentPercentage = 0
				
				if (result == WIN_TRAITOR) then
					traitorPercentage = 0.5 + (tProportion / 4)
					detectivePercentage = (1 - traitorPercentage) * (0.13 + (numDetectives / numInnocents))
					innocentPercentage = 1 - traitorPercentage - detectivePercentage
				else
					traitorPercentage = 0.25 + (tProportion / 4)
					detectivePercentage = (1 - traitorPercentage) * (0.16 + (numDetectives / numInnocents))
					innocentPercentage = 1 - traitorPercentage - detectivePercentage
				end
				
				traitorPool = traitorPercentage * moneyPool
				detectivePool = detectivePercentage * moneyPool
				innocentPool = innocentPercentage * moneyPool
				
				traitorPay = traitorPool / numTraitors
				detectivePay = detectivePool / numDetectives
				innocentPay = innocentPool / numInnocents
				
				PrintMessage(2, "got here")
				if pprint then
					message = "GC TEST PAY\nTraitor Pay: " .. traitorPay .. "\nDetective Pay: " .. detectivePay ..
						"\nInnocent Pay: " .. innocentPay
					PrintMessage(2, message)
				end
			end
		end
		return ""
	end
end