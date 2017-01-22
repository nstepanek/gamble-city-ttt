
-- returns true if str starts with phrase
function string.starts(str, phrase)
	return string.sub(str, 1, string.len(phrase)) == phrase
end

function string.isnumber(str)
	return tonumber(str) ~= nil 
end

print("$ string_utils.lua        $")