

function coinToss(ply, text, team)
	text = string.lower(text)
	if string.starts(text, "!cointoss") then
		wordTable = {}
		count = 0
		for word in string.gmatch(text, '([^ ]+)') do
			wordTable[count] = word
			count = count + 1
		end
		
		if count == 3 then
			if string.isnumber(wordTable[1]) then
				wager = tonumber(wordTable[1])
				pick = wordTable[2]
				money = ply:GetNWInt("money")
				if string.starts(pick, "t") or string.starts(pick, "h") then
					if string.starts(pick, "h") then
						pick = 0
					else
						pick = 1
					end
					if wager > 0 then
						if money >= wager then
							flip = math.random(0, 1)
							if pick == flip then
								money = money + wager
								ply:SetNWInt("money", money)
								if pick == 0 then
									ply:ChatPrint("Heads! You have won $" .. tostring(wager) .. ".")
								else
									ply:ChatPrint("Tails! You have won $" .. tostring(wager) .. ".")
								end
							else
								money = money - wager
								ply:SetNWInt("money", money)
								if pick == 0 then
									ply:ChatPrint("Heads, you have lost $" .. tostring(wager) .. ".")
								else
									ply:ChatPrint("Tails, you have lost $" .. tostring(wager) .. ".")
								end
							end
						else
							ply:ChatPrint("You can only wager what you have.")
						end
					else
						ply:ChatPrint("Enter a wager greater than 0.")
					end
				else
					ply:ChatPrint("Must select heads or tails.")
				end
			else
				ply:ChatPrint("Wager must be a number.")
			end
		else
			ply:ChatPrint("Usage: !cointoss [wager] [heads/tails]")
		end
		return ""
	end
end

hook.Add("PlayerSay", "CoinToss", coinToss)


print("$ coin_toss.lua           $")