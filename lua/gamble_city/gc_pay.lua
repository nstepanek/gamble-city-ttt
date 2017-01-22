
pprint = true

function buildPlayers()
	for i, p in ipairs(player.GetAll()) do
		p:SetNWInt("tKills", 0)
		p:SetNWInt("iKills", 0)
		p:SetNWInt("dKills", 0)
		p:SetNWInt("tDamage", 0)
		p:SetNWInt("iDamage", 0)
		p:SetNWInt("dDamage", 0)
		p:SetNWInt("goodKills", 0)
		p:SetNWInt("goodDamage", 0)
		p:SetNWInt("badKills", 0)
		p:SetNWInt("badDamage", 0)
	end
end

function addPlayerDamage(victim, attacker, healthRemaining, damageTaken)
	if !(IsValid(victim) && IsValid(attacker)) then 
		return 
	end
	
	if damageTaken > 100 then
		damageTaken = 100
	end
	
	if attacker:IsPlayer() then
		attackerSteamID = attacker:SteamID()
		print("GC: Damage by " .. attackerSteamID)
		attackerRole = attacker:GetRole()
		victimRole = victim:GetRole()
		if ((attackerRole == ROLE_TRAITOR and victimRole != ROLE_TRAITOR) or (attackerRole != ROLE_TRAITOR and victimRole == ROLE_TRAITOR)) then
			goodDamage = attacker:GetNWInt("goodDamage")
			attacker:SetNWInt("goodDamage", goodDamage + damageTaken)
			if (healthRemaining <= 0) then
				goodKills = attacker:GetNWInt("goodKills")
				attacker:SetNWInt("goodKills", goodKills + 1)
			end
		else
			badDamage = attacker:GetNWInt("badDamage")
			attacker:SetNWInt("badDamage", badDamage + damageTaken)
			if (healthRemaining <= 0) then
				badKills = attacker:GetNWInt("badKills")
				attacker:SetNWInt("badKills", badKills + 1)
			end
		end
		
	else
		print("GC: Damage by non-player")
	end
end

function printPlayerStats(ply, text, team)
	text = string.lower(text)
	
	if (text == "!playerstats") then
		for i, p in ipairs(player.GetAll()) do
			message = p:SteamID() .. " goodDamage: " .. tostring(p:GetNWInt("goodDamage")) .. " badDamage: " .. tostring(p:GetNWInt("badDamage")) ..
				" goodKills: " .. tostring(p:GetNWInt("goodKills")) .. " badKills: " .. tostring(p:GetNWInt("badKills"))
			ply:PrintMessage(2, message)
		end
		return ""
	end
end

function getPlayerCounts()
	local playerCounts = {total = 0, traitor = 0, innocent = 0, detective = 0}
	for i, p in pairs(player.GetAll()) do
		playerCounts["total"] = playerCounts["total"] + 1
		role = p:GetRole()
		if role == ROLE_TRAITOR then
			playerCounts["traitor"] = playerCounts["traitor"] + 1
		elseif role == ROLE_INNOCENT then
			playerCounts["innocent"] = playerCounts["innocent"] + 1
		elseif role == ROLE_DETECTIVE then
			playerCounts["detective"] = playerCounts["detective"] + 1
		end
	end
	
	return playerCounts
end

function pay(result)
	playerCounts = getPlayerCounts()
	numPlayers = playerCounts["total"]
	numTraitors = playerCounts["traitor"]
	numDetectives = playerCounts["detective"]
	numInnocents = playerCounts["innocent"]
	numGood = numDetectives + numInnocents
	
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
	
	baseTPay = (traitorPool / numTraitors) * 0.7
	baseDPay = (detectivePool / numDetectives) * 0.7
	baseIPay = (innocentPool / numInnocents) * 0.7
	
	tBonusPool = traitorPool * 0.3
	dBonusPool = detectivePool * 0.3
	iBonusPool = innocentPool * 0.3
	
	if numTraitors <= 0 then
		traitorPay = 0
	end
	if numDetectives <= 0 then
		detectivePay = 0
	end
	if numInnocents <= 0 then
		innocentPay = 0
	end
	
	if pprint then
		message = "GC END ROUND PAY\nTraitor Pay: " .. traitorPay .. "\nDetective Pay: " .. detectivePay ..
			"\nInnocent Pay: " .. innocentPay
		PrintMessage(2, message)
	end
	
	tPoints = 0
	dPoints = 0
	iPoints = 0
	for i, p in pairs(player.GetAll()) do
		role = p:GetRole()
		goodKills = p:GetNWInt("goodKills")
		goodDamage = p:GetNWInt("goodDamage")
		badKills = p:GetNWInt("badKills")
		badDamage = P:GetNWInt("badDamage")
		
		points = (goodKills * 25) + goodDamage
		if (badKills == 0 and badDamage == 0) then
			points = points + 70
		elseif (badKills == 0 and badDamage < 25) then
			points = points + 35
		end
		
		if role == ROLE_TRAITOR then
			tPoints = tPoints + points
		elseif role == ROLE_INNOCENT then
			iPoints = iPoints + points
		elseif role == ROLE_DETECTIVE then
			dPoints = dPoints + points
		end
		
		p:SetNWInt("roundPoints", points)
	end
	
	allMessage = "Round Payments"
	for i, p in pairs(player.GetAll()) do
		role = p:GetRole()
		curMoney = p:GetNWInt("money")
		points = p:GetNWInt("roundPoints")
		pay = 0
		pool = 0
		
		if role == ROLE_TRAITOR then
			pay = baseTPay
			pay = pay + (tBonusPool * (points / tPoints))
		elseif role == ROLE_INNOCENT then
			pay = baseIPay
			pay = pay + (iBonusPool * (points / iPoints))
		elseif role == ROLE_DETECTIVE then
			pay = baseDPay
			pay = pay + (dBonusPool * (points / dPoints))
		end
		
		
		p:SetNWInt("money", curMoney + pay)
		p:PrintMessage(3, "You earned $" .. tostring(pay) .. " this round. $" .. tostring(curMoney) .. " -> $" .. tostring(curMoney + pay))
		allMessage = allMessage .. "\n" .. p:SteamID() .. " $" .. tostring(curMoney) .. " -> $" .. tostring(curMoney + pay)
		save(p)
	end
	
	PrintMessage(2, allMessage)
end


hook.Add("TTTBeginRound", "BuildPlayers", buildPlayers)
hook.Add("PlayerHurt", "AddPlayerDamage", addPlayerDamage)
hook.Add("PlayerSay", "PrintPlayerStats", printPlayerStats)
hook.Add("TTTEndRound", "Pay", pay)



print("$ gc_pay.lua              $")