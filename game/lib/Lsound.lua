---=====================================
---luastg sound
---=====================================

----------------------------------------
---SE

local sound_effect = {}

---加载音效
---@param name string
---@param path string
---@param volume number|nil @默认音量
function LoadSound(name, path, volume)
	sound_effect[name] = {
		name,
		volume,
		path,
	}
	lstg.LoadSound(name, path)
end

---播放音效
---@param name string
---@param vol number
---@param pan number
---@param usevol boolean|nil @使用指定音量而不是默认音量
function PlaySound(name, vol, pan, usevol)
	local v
	if not usevol then
		if sound_effect[name] then
			v = sound_effect[name][2]
			if v == nil then
				v = vol
			end
		else
			v = vol
		end
	else
		v = vol
	end
	lstg.PlaySound(name, v, pan)
end
