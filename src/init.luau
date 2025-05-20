--!native
--!optimize 2

-- UID
-- Ratchanon Suwatsiriphol

local HttpService = game:GetService("HttpService")
local GenerateGUID = HttpService.GenerateGUID
local GlobalRandomizer = Random.new()
local NextInteger = GlobalRandomizer.NextInteger

--[=[
	@class UID
	An uid generator to represent an uniqueness for Roblox
]=]
local UID = {}
UID.__index = UID

--- Creates a new UID generator instance
---
--- @within UID
--- @function new
--- @param seed number? -- Optional seed for the randomizer. Must be in range [-9007199254740991, 9007199254740991].
--- @return UID -- A new UID generator instance.
function UID.new(seed: number?)
	return setmetatable({
		Randomizer = Random.new(seed),
	}, UID)
end

--- Supported UID base formats
---
--- @type UIDBase "Base256ASCII" | "Base94JSONSAFE" | "Base64URL" | "Hex" | "GUID"
--- @within UID
export type UIDBase = "Base256ASCII" | "Base94JSONSAFE" | "Base64URL" | "Hex" | "GUID"

--- Validates a UID against a specified base format
---
--- @within UID
--- @function isbase
--- @param uid string -- The UID to validate.
--- @param uidBase UIDBase -- The base format to validate against.
--- @return boolean -- Whether the UID matches the specified base format.
function UID.isbase(uid: string, uidBase: UIDBase): boolean
	if uidBase == "Hex" then
		return string.find(uid, "^[0-9A-Fa-f]+$") ~= nil
	elseif uidBase == "GUID" then
		return string.find(
			uid,
			"^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
		) ~= nil
	elseif uidBase == "Base64URL" then
		return string.find(uid, "^[A-Za-z0-9%-_]+$") ~= nil
	elseif uidBase == "Base94JSONSAFE" then
		return string.find(
			uid,
			"^[0-9a-zA-Z!#$%%&'()*+,-./:;<=>?@%[%]^_`{|}~" .. string.char(127) .. "]+$"
		) ~= nil
	elseif uidBase == "Base256ASCII" then
		return true -- Since every text character, emoji is based on ASCII at a fundamental level.
	end

	return false
end

--- Generates a new GUID string
---
--- @within UID
--- @function guid
--- @return string -- A GUID string. Uniqueness is 2^128 possibilities (128-bit).
function UID.guid()
	return GenerateGUID(HttpService, false)
end

type UID = typeof(UID.new())

local STRING_CACHES = table.create(16)

--[[
	@param input {number} -- Array of bytes to build string from
	@param length number? -- Optional length to limit the string
	@return string -- Built string from bytes
]]
local function stringBuilder(input: { number }, length: number?): string
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

--- Generates a new Base256ASCII string
---
--- @param length number -- The length of the UID. Uniqueness is (256 ^ length) possibilities.
--- @return string -- A random Base256ASCII string.
function UID:NextBase256ASCII(length: number)
	local self = self :: UID

	local Randomizer = self.Randomizer or GlobalRandomizer

	for i = 1, length do
		blockBase256ASCII[i] = NextInteger(Randomizer, 0, 255)
	end

	return stringBuilder(blockBase256ASCII, length)
end

local blockBase94JSONSAFE = table.create(16)
local BASE_94_JSONSAFE_CHARACTERS = {
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"!",
	"#",
	"$",
	"%",
	"&",
	"'",
	"(",
	")",
	"*",
	"+",
	",",
	"-",
	".",
	"/",
	":",
	";",
	"<",
	"=",
	">",
	"?",
	"@",
	"[",
	"]",
	"^",
	"_",
	"`",
	"{",
	"|",
	"}",
	"~",
	string.char(127),
}

--- Generates a new Base94JSONSAFE string
---
--- @param length number -- The length of the UID. Uniqueness is (94 ^ length) possibilities.
--- @return string -- A random Base94JSONSAFE string.
function UID:NextBase94JSONSAFE(length: number)
	local self = self :: UID

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
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"-",
	"_",
}

--- Generates a new Base64URL string
---
--- @param length number -- The length of the UID. Uniqueness is (64 ^ length) possibilities.
--- @return string -- A random Base64URL string.
function UID:NextBase64URL(length: number)
	local self = self :: UID
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

--[[
	@param Randomizer Random -- The randomizer instance
	@param length number -- The length of the hex string to generate
	@return {number} -- Array of processed hex blocks
]]
local function process16C15(Randomizer: Random, length: number): { number }
	local iteration = length // 15

	table.clear(blockOf16C15)

	for i = 1, iteration do
		blockOf16C15[i] = NextInteger(Randomizer, min16C15, max16C15)
	end

	local remainder = length % 15

	if remainder > 0 then
		blockOf16C15[iteration + 1] =
			NextInteger(Randomizer, 16 ^ (remainder - 1) - 1, 16 ^ remainder - 1)
	end

	return blockOf16C15
end

--[[
	@param input {number} -- Array of processed hex blocks
	@return string -- Built hex string
]]
local function stringBuilderHexBlock16C15(input: { number }): string
	local inputLength = #input

	for i = 1, inputLength, 7997 do
		local j = math.min(i + 7996, inputLength)
		local alloc = (j - i) + 1

		table.insert(
			STRING_CACHES,
			string.format(string.rep([[%x]], alloc), table.unpack(input, i, j))
		)
	end

	local blockOfString = table.concat(STRING_CACHES)
	table.clear(STRING_CACHES)

	return blockOfString
end

--- Generates a new Hex string
---
--- @param length number -- The length of the UID. Uniqueness is (16 ^ length) possibilities.
--- @return string -- A random Hex string.
function UID:NextHex(length: number)
	local self = self :: UID
	local Randomizer = self.Randomizer or GlobalRandomizer
	local blockOf16C13 = process16C15(Randomizer, length)

	return stringBuilderHexBlock16C15(blockOf16C13)
end

--- Clones the UID object
---
--- @return UID -- A new UID object with the same state as the original.
function UID:Clone()
	local self = self :: UID
	local newUIDObject = table.clone(self)
	newUIDObject.Randomizer = typeof(self.Randomizer) == "Random" and self.Randomizer:Clone()
		or nil

	return setmetatable(newUIDObject, UID)
end

return UID
