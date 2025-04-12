--[[
	@Dev_Bas
	Token v3.0.1:
	A typed Roblox module for generating tokens to represent uniqueness.
]]

--!native
--!optimize 2

local HttpService = game:GetService("HttpService")
local GenerateGUID = HttpService.GenerateGUID
local GlobalRandomizer = Random.new()
local NextInteger = GlobalRandomizer.NextInteger

--[=[
	@class Token
	A utility class for generating unique tokens in various formats.
]=]
local Token = {}
Token.__index = Token

--[=[
	@within Token
	@function new
	@param seed number? -- Optional seed for the randomizer. Must be in range [-9007199254740991, 9007199254740991].
	@return Token -- A new Token generator instance.
]=]
function Token.new(seed: number?)
	return setmetatable({
		Randomizer = Random.new(seed)	
	}, Token)
end

type TokenBase = ("Base256ASCII" | "Base94JSONSAFE" | "Base64URL" | "Hex" | "GUID")

--[=[
	@within Token
	@function isbase
	@param token string -- The token to validate.
	@param tokenBase TokenBase -- The base format to validate against.
	@return boolean -- Whether the token matches the specified base format.
]=]
function Token.isbase(token: string, tokenBase: TokenBase): boolean
	if tokenBase == "Hex" then
		return string.find(token, "^[0-9A-Fa-f]+$") ~= nil
	elseif tokenBase == "GUID" then
		return string.find(token, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
	elseif tokenBase == "Base64URL" then
		return string.find(token, "^[A-Za-z0-9%-_]+$") ~= nil
	elseif tokenBase == "Base94JSONSAFE" then
		return string.find(token, "^[0-9a-zA-Z!#$%%&'()*+,-./:;<=>?@%[%]^_`{|}~"..string.char(127).."]+$") ~= nil
	elseif tokenBase == "Base256ASCII" then 
		return true -- Since every text character, emoji is based on ASCII at a fundamental level.
	end
	
	return false
end

--[=[
	@within Token
	@function guid
	@return string -- A GUID string. Uniqueness is 2^128 possibilities (128-bit).
]=]
function Token.guid()
	return GenerateGUID(HttpService, false)
end

type Token = typeof(Token.new())

local STRING_CACHES = table.create(16)

--- Internal function to build a string from an array of bytes.
local function stringBuilder(input: {number}, length: number?): string
	local inputLength = if length then math.min(#input, length) else #input
	
	for i = 1, inputLength, 7997 do
		local j = math.min(i + 7996, inputLength)
		table.insert(STRING_CACHES, string.char(table.unpack(input, i, j)))
	end

	local blockOfString = table.concat(STRING_CACHES)
	table.clear(STRING_CACHES)

	return blockOfString
end

local blockBase256ASCII = table.create(32, 0)

--[=[
	@within Token
	@function NextBase256ASCII
	@param length number -- The length of the token. Uniqueness is (256 ^ length) possibilities.
	@return string -- A random Base256ASCII string.
]=]
function Token:NextBase256ASCII(length: number)
	local self = self :: Token

	local Randomizer = self.Randomizer or GlobalRandomizer
	
	for i = 1, length do
		blockBase256ASCII[i] = NextInteger(Randomizer, 0, 255)
	end
	
	return stringBuilder(blockBase256ASCII, length)
end

local blockBase94JSONSAFE = table.create(16)
local BASE_94_JSONSAFE_CHARACTERS = {
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
	"q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
	"Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"!", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", ":",
	";", "<", "=", ">", "?", "@", "[", "]", "^", "_", "`", "{", "|", "}", "~",
	string.char(127)
}

--[=[
	@within Token
	@function NextBase94JSONSAFE
	@param length number -- The length of the token. Uniqueness is (94 ^ length) possibilities.
	@return string -- A random Base94JSONSAFE string.
]=]
function Token:NextBase94JSONSAFE(length: number)
	local self = self :: Token

	local Randomizer = self.Randomizer or GlobalRandomizer
	
	for i = 1, length do
		local pointer = NextInteger(Randomizer, 1, 93)
		blockBase94JSONSAFE[i] = BASE_94_JSONSAFE_CHARACTERS[pointer]
	end
	
	local blockOfString = table.concat(blockBase94JSONSAFE)
	table.clear(blockBase94JSONSAFE)

	return blockOfString
end

local blockBase64URL = table.create(16)
local BASE_64_URL_CHARACTERS = {
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
	"Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
	"g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
	"w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "_"
}

--[=[
	@within Token
	@function NextBase64URL
	@param length number -- The length of the token. Uniqueness is (64 ^ length) possibilities.
	@return string -- A random Base64URL string.
]=]
function Token:NextBase64URL(length: number)
	local self = self :: Token
	local Randomizer = self.Randomizer or GlobalRandomizer
	
	for i = 1, length do
		local pointer = NextInteger(Randomizer, 1, 64)
		blockBase64URL[i] = BASE_64_URL_CHARACTERS[pointer]
	end
	
	local blockOfString = table.concat(blockBase64URL)
	table.clear(blockBase64URL)
	
	return blockOfString
end

local blockOf16C15 = table.create(16)
local min16C15, max16C15 = 16 ^ (15 - 1) - 1, 16 ^ 15 - 1 

--- Internal function to process Hex blocks.
local function process16C15(Randomizer: Random, length: number): {number}
	local iteration = length // 15
	
	table.clear(blockOf16C15)
	
	for i = 1, iteration do
		blockOf16C15[i] = NextInteger(Randomizer, min16C15, max16C15)
	end
	
	local remainder = length % 15
	
	if remainder > 0 then
		blockOf16C15[iteration + 1] = NextInteger(Randomizer, 16 ^ (remainder - 1) - 1, 16 ^ remainder - 1)
	end
	
	return blockOf16C15
end

--- Internal function to build a Hex string from processed blocks.
local function stringBuilderHexBlock16C15(input: {number}): string
	local inputLength = #input
	
	for i = 1, inputLength, 7997 do
		local j = math.min(i + 7996, inputLength)
		local alloc = (j - i) + 1
		
		table.insert(STRING_CACHES, string.format(string.rep([[%x]], alloc), table.unpack(input, i, j)))
	end
	
	local blockOfString = table.concat(STRING_CACHES)
	table.clear(STRING_CACHES)
	
	return blockOfString
end

--[=[
	@within Token
	@function NextHex
	@param length number -- The length of the token. Uniqueness is (16 ^ length) possibilities.
	@return string -- A random Hex string.
]=]
function Token:NextHex(length: number)	
	local self = self :: Token
	local Randomizer = self.Randomizer or GlobalRandomizer
	local blockOf16C13 = process16C15(Randomizer, length)
	
	return stringBuilderHexBlock16C15(blockOf16C13)
end

--[=[
	@within Token
	@function Clone
	@return Token -- A new Token object with the same state as the original.
]=]
function Token:Clone()
	local self = self :: Token
	local newTokenObject = table.clone(self)
	
	newTokenObject.Randomizer = typeof(self.Randomizer) == "Random" and self.Randomizer:Clone() or nil
	
	return setmetatable(newTokenObject, Token)
end

return Token
