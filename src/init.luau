--[[
	@Dev_Bas
	Token v1.0.0:
	A typed roblox module for generate token to represent an uniqueness.
]]

--!native
--!optimize 2

local GlobalRandomizer = Random.new()
local NextInteger = GlobalRandomizer.NextInteger

--[=[
	class Token
]=]
local Token = {}
Token.__index = Token

--[=[
	Returns a new token generator using an optional seed.
	Seed number must be in range [-9007199254740991, 9007199254740991]. (53 bit integer)
<strong>
	@return Token
</strong><p><em>--Style: Moonwave Documentation</em>
]=]
function Token.new(seed: number?)
	return setmetatable({
		Randomizer = Random.new(seed)	
	}, Token)
end

type TokenBase = ("Base64URL" | "Hex" | "GUID")

function Token.isbase(token: string, tokenBase: TokenBase): boolean
	if tokenBase == "Hex" then
		return string.find(token, "^[0-9A-Fa-f]+$") ~= nil
	elseif tokenBase == "Base64URL" then
		return string.find(token, "^[A-Za-z0-9%-_]+$") ~= nil
	elseif tokenBase == "GUID" then
		return string.find(token, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
	end
	return false
end

local HttpService = game:GetService("HttpService")
local GenerateGUID = HttpService.GenerateGUID

--[=[
	Returns a GUID string. (HttpService optimized)
	Uniqueness is 2^128 possibility. (128 bit)
<strong>
	@return string --token GUID
</strong><p><em>--Style: Moonwave Documentation</em>
]=]
function Token.guid()
	return GenerateGUID(HttpService, false)
end

type Token = typeof(Token.new())

local BASE_64_URL_CHARACTERS = {
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
	"Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
	"g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
	"w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "_"
}

--[=[
	Returns a random Base64URL string.
	If the method were call with no token generator, it'll using global token generator by default.
<strong>
	@param length: number --Uniqueness is (64 ^ length) possibility.

	@return string --token Base64URL
</strong><p><em>--Style: Moonwave Documentation</em>
]=]
function Token:NextBase64URL(length: number)
	local self = self :: Token
	local Randomizer = self.Randomizer or GlobalRandomizer
	local block = table.create(length)
	for i = 1, length do
		block[i] = NextInteger(Randomizer, 1, #BASE_64_URL_CHARACTERS)
	end
	for i, byte in ipairs(block) do
		block[i] = BASE_64_URL_CHARACTERS[byte]
	end
	return table.concat(block)
end

-- why C13 because if C14 it is consider unsafe for random an integer since 16^14 > 2^53 (53 bit) while 16^13 < 2^53 which is safe.
local min16C13, max16C13 = 16 ^ (13 - 1) - 1, 16 ^ 13 - 1 
--- Takes an array of bytes and builds a string out of it.
--- Uses `4096` byte chunks to make the string, which ends up being very fast.
local function process16C13(Randomizer: Random, length: number): {number}
	local iteration = length // 13
	local blockOf16C13 = table.create(iteration + 1)
	for i = 1, iteration do
		blockOf16C13[i] = NextInteger(Randomizer, min16C13, max16C13) -- 13
	end
	local remainder = length % 13
	if remainder > 0 then
		blockOf16C13[#blockOf16C13 + 1] = NextInteger(Randomizer, 16 ^ (remainder - 1) - 1, 16 ^ remainder - 1)
	end
	return blockOf16C13
end
local STRING_HEXS = table.create(5)
local function buildHexBlock16C13(input: {number}): string
	local inputLength = #input
	for i = 1, inputLength, 4096 do
		local j = math.min(i + 4095, inputLength)
		local alloc = (j - i) + 1
		table.insert(STRING_HEXS, string.format(string.rep([[%x]], alloc), table.unpack(input, i, j)))
	end
	local blockOfString = table.concat(STRING_HEXS)
	table.clear(STRING_HEXS)
	return blockOfString
end

--[=[
	Returns a random Hex string.
	If the method were call with no token generator, it'll using global token generator by default.
<strong>
	@param length: number --Uniqueness is (16 ^ length) possibility.

	@return string --token Hex
</strong><p><em>--Style: Moonwave Documentation</em>
]=]
function Token:NextHex(length: number)	
	local self = self :: Token
	local Randomizer = self.Randomizer or GlobalRandomizer
	local blockOf16C13 = process16C13(Randomizer, length)
	return buildHexBlock16C13(blockOf16C13)
end

return Token