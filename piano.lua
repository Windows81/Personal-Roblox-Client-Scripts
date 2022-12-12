--[==[HELP]==
-- Credit to https://github.com/0b5vr/Lua_midiParser/blob/master/midi-parser.lua for the MIDI parser.
-- Tested with JJSploit and should work with Synapse X or KRNL (not tested).

[1] - string
	The file path from which the MIDI shall be parsed, relative to ./workspace

[2] - number
	The integer number of semitones to transpose the piece by; default is 0.

[3] - number
	The speed at which the track shall be played; default is 1.

[4] - (number)->() | nil
	The function that receives MIDI-on codes; default is
		getsenv(game.Players.LocalPlayer.PlayerGui.PianoGui.Main).PlayNoteClient.

[5] - { (12x) number }
	Pitch-shift values for each note in cents, starting from C.
]==] --
--
local args = _E and _E.ARGS or {}
local FILEPATH = args[1]
local TRANSPOSE = args[2] or 0
local SPEED = args[3] or 1
local PLAY_NOTE = args[4]
local PITCH_SHIFTS = args[5] or table.create(12, 0)
local OTHER_ARGS = {unpack(args, 6)}

local function shift(midi_n)
	local i = math.round(midi_n) % 12 + 1
	return midi_n + PITCH_SHIFTS[i] / 100 + TRANSPOSE
end

if not PLAY_NOTE then
	local play_hooks = {
		function()
			local senv = getsenv(game.Players.LocalPlayer.PlayerGui.PianoGui.Main)
			local hook = senv.PlayNoteClient
			return function(n) hook(math.round(n - 35)) end
		end,

		-- Ro-Xolotl player (microtones are supported).
		function()
			local log_mod = game.Workspace:FindFirstChild('PianoLogic', true)
			local sft_mod = log_mod.Parent.Parent.Dependencies.Soundfonts
			local sft = require(sft_mod)[OTHER_ARGS[1] or 1]
			local hook = require(log_mod).PlayNote
			return function(midi_note)
				local h =
					game.Players.LocalPlayer.Character:FindFirstChildWhichIsA 'Humanoid'
				if not h then error'No humanoid found.' end
				local s = h.SeatPart
				if not s then error'Character is not sat.' end

				local arg_note = midi_note - 35
				local arg_offset = sft.Offset
				local ids = sft.AssetIds
				if arg_note >= 1 and arg_note <= 61 then
					local int_note = math.floor(midi_note - 35)
					local note_per_oct = (int_note - 1) % 12 + 1
					local id_i = math.ceil(note_per_oct / 2)
					ids = table.create(6, ids[id_i])

					local octave = math.ceil(int_note / 12)
					arg_note = 61 + midi_note % 1
					local offset = 8 * (2 * (octave - 1) + (1 - int_note % 2))
					arg_offset = sft.Offset + offset - 80
				end
				local tag = game:GetService 'CollectionService':GetTags(s.Parent)[1]
				local hook_args = {
					tag,
					arg_note,
					nil,
					ids,
					arg_offset,
					sft.MaxLifetime,
					sft.Fadeout,
					0,
					false,
					100,
					100,
					sft.VolumeModifier,
					false,
					0,
				}
				hook(unpack(hook_args))
			end
		end,
	}
	local s
	for _, f in next, play_hooks do
		s, PLAY_NOTE = pcall(f)
		if s then break end
	end
	if not s then warn'Unable to find an appropriate piano hook.' end
end

if _G.midi_conn then _G.midi_conn:Disconnect() end
if FILEPATH == nil then
	FILEPATH = [[boo.mid]]
elseif not FILEPATH then
	return
elseif #PITCH_SHIFTS ~= 12 then
	warn'The PITCH_SHIFTS table does not have twelve elements.'
	return
end

--[[
local d = 12 / 11
for i = 0, 24, d do
	PLAY_NOTE(33 + i)
	PLAY_NOTE(33 + i + (1 * i + 1) * d)
	PLAY_NOTE(33 + i + (2 * i + 1) * d)
	task.wait(1)
end
error'666'
]]

--[[
for i = 0, 10, 0.125 do
	PLAY_NOTE(33 + i)
	task.wait(.5)
end
error'666'
]]

--[[
for i = 2, 8, 0.125 do
	local p = math.floor(13 * math.sin(i * math.pi) + 15)
	local b = 33 + 12 * math.log(50 / 55, 2)
	PLAY_NOTE(b + 12 * math.log(p / 8, 2))
	PLAY_NOTE(b)
	task.wait(.5)
end
error'666'
]]

local midi = readfile(FILEPATH)
local function byte_array(s, l)
	local r = {}
	for i = 1, l do r[i] = string.byte(midi, i + s - 1) end
	return r
end

local function byte_to_num(s, l)
	local r = 0
	for i = 1, l do r = r + string.byte(midi, i + s - 1) * math.pow(256, l - i) end
	return r
end

-- Variable-length Quantity.
local function vlq(s)
	local retNumber = 0
	local head = 0
	local byte = 0
	repeat
		byte = string.byte(midi, s + head)
		retNumber = retNumber * 128 + (byte - math.floor(byte / 128) * 128)
		head = head + 1
	until math.floor(byte / 128) ~= 1
	return retNumber, head
end

local function table_eq(a, b)
	for i = 1, #a do if a[i] ~= b[i] then return false end end
	return true
end

local head = 1
if not table_eq(byte_array(head, 4), {77, 84, 104, 100}) then
	error('input file seems not to be a .mid file')
end
-- +4 for header chunk magic number; +4 for header chunk length.
head = head + 8
local format = byte_to_num(head, 2)
if format ~= 0 and format ~= 1 then error('not supported such format of .mid') end

-- +2 for format; +2 for track count.
head = head + 4
local tempo = 500000
head = head + 2

local notet = 0
local tracki = 0
_G.midi_index = {}
_G.midi_notes = {}
local cdelta = {}
while head < string.len(midi) do
	-- If chunk is not track chunk.
	if not table_eq(byte_array(head, 4), {77, 84, 114, 107}) then
		-- Unknown chunk magic number.
		head = head + 4
		-- Chunk length + chunk data.
		head = head + 4 + byte_to_num(head, 4)

	else
		tracki = tracki + 1
		_G.midi_notes[tracki] = {}
		_G.midi_index[tracki] = 1
		cdelta[tracki] = 0
		notet = 0

		-- Track chunk magic number.
		head = head + 4

		local chnkl = byte_to_num(head, 4)
		-- Chunk length
		head = head + 4
		local chnks = head

		local cstat = 0
		while head < chnks + chnkl do
			-- Timing.
			local dtime, dhead = vlq(head)
			notet = notet + dtime
			head = head + dhead

			local tstat = byte_array(head, 1)[1]

			-- Event; running status.
			if math.floor(tstat / 128) == 1 then
				head = head + 1
				cstat = tstat
			end

			local t = math.floor(cstat / 16)
			local chan = cstat - t * 16

			if t == 9 then -- Note on.
				local data = byte_array(head, 2)
				local t = _G.midi_notes[tracki]
				t[#t + 1] = {notet, unpack(data)}
				head = head + 2
				notet = 0

			elseif t == 8 then -- Note off.
				head = head + 2

			elseif t == 10 then -- Polyphonic keypressure.
				head = head + 2

			elseif t == 11 then -- Control change.
				head = head + 2

			elseif t == 12 then -- Program change.
				head = head + 1

			elseif t == 13 then -- Channel pressure.
				head = head + 1

			elseif t == 14 then -- Pitch bend.
				head = head + 2

			elseif cstat == 255 then -- Meta event.
				local metaType = byte_array(head, 1)[1]
				head = head + 1
				local metaLength, metaHead = vlq(head)

				if metaType == 3 then -- Track name.
					head = head + metaHead + metaLength

				elseif metaType == 4 then -- Instrument name.
					head = head + metaHead + metaLength

				elseif metaType == 5 then -- Lyric.
					head = head + metaHead + metaLength

				elseif metaType == 47 then -- End of track.
					head = head + 1
					break

				elseif metaType == 81 then -- Tempo.
					head = head + 1
					tempo = byte_to_num(head, 3)
					head = head + 3

				elseif metaType == 88 then -- Time signature.
					head = head + 5

				elseif metaType == 89 then -- Key signature.
					head = head + 3

				else
					head = head + metaHead + metaLength
				end
			end
		end
	end
end

if SPEED > 0 then
	_G.midi_conn = game:GetService 'RunService'.RenderStepped:Connect(
		function(d)
			local keep = false
			for i, mn in next, _G.midi_notes do
				local mi = _G.midi_index[i]
				cdelta[i] = cdelta[i] + d / tempo * SPEED * 1e8
				if mi <= #mn then keep = true end
				while mi <= #mn and cdelta[i] >= mn[mi][1] do
					cdelta[i] = cdelta[i] - mn[mi][1]
					task.spawn(
						function()
							local n = shift(mn[mi][2])
							local s, e = pcall(PLAY_NOTE, n)
							if not s then
								_G.midi_conn:Disconnect()
								error(e)
							end
						end)
					mi = mi + 1
				end
				_G.midi_index[i] = mi
			end
			if not keep then _G.midi_conn:Disconnect() end
		end)
end

return PLAY_NOTE
