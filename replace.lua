local d, g, r = debug, getgc, getreg
local rs, pls = game:GetService("RunService"), game:GetService("Players")
local nc, idx, nidx = hookmetamethod(game, "__namecall"), hookmetamethod(game, "__index"), hookmetamethod(game, "__newindex")

local X = {
	cache = setmetatable({}, {__mode = "kv"}),
	stored = {},
	hooks = {}
}

local function t_str(t, l)
	l = l or 0
	local s = string.rep("  ", l) .. "{\n"
	for k, v in next, t do
		local kt = type(k) == "string" and '"' .. k .. '"' or tostring(k)
		if type(v) == "table" and l < 3 then
			s = s .. string.rep("  ", l + 1) .. "[" .. kt .. "] = " .. t_str(v, l + 1) .. ",\n"
		else
			s = s .. string.rep("  ", l + 1) .. "[" .. kt .. "] = " .. tostring(v) .. ",\n"
		end
	end
	return s .. string.rep("  ", l) .. "}"
end

local function deep_patch(o, k, v)
	if type(o) ~= "table" then return end
	if rawget(o, k) ~= nil then rawset(o, k, v) end
	for _, sub in next, o do
		if type(sub) == "table" and not X.cache[sub] then
			X.cache[sub] = true
			deep_patch(sub, k, v)
		end
	end
end

X.extreme = function(target, val)
	local v_type = type(val)
	local genv = getgenv()
	if rawget(genv, target) ~= nil then genv[target] = val end
	
	for _, o in next, g(true) do
		local ot = type(o)
		if ot == "function" and islclosure(o) then
			local function scan_proto(f)
				local cnsts = d.getconstants(f)
				if table.find(cnsts, target) then
					for i, c in next, cnsts do
						if c == target then pcall(d.setconstant, f, i, val) end
					end
					for i, uv in next, d.getupvalues(f) do
						if type(uv) == v_type then pcall(d.setupvalue, f, i, val) end
					end
				end
				for _, pr in next, d.getprotos(f) do scan_proto(pr) end
			end
			pcall(scan_proto, o)
			local env = getfenv(o)
			if rawget(env, target) ~= nil then env[target] = val end
		elseif ot == "table" then
			deep_patch(o, target, val)
			local src = d.getinfo(o).source
			if src and src:find(target) then
				for k, _ in next, o do
					if type(o[k]) == v_type then rawset(o, k, val) end
				end
			end
		end
	end
	
	for _, rg in next, r() do
		if type(rg) == "table" then deep_patch(rg, target, val) end
	end
end

X.hijack = function(cfg)
	local old_nc
	old_nc = hookmetamethod(game, "__namecall", function(self, ...)
		local m = getnamecallmethod()
		if not checkcaller() then
			for k, v in next, cfg do
				if m == k or self.Name == k then return unpack(type(v) == "table" and v or {v}) end
			end
		end
		return old_nc(self, ...)
	end)
	
	local old_idx
	old_idx = hookmetamethod(game, "__index", function(t, k)
		if not checkcaller() and typeof(t) == "Instance" then
			for class, props in next, cfg do
				if t:IsA(class) and props[k] ~= nil then return props[k] end
			end
		end
		return old_idx(t, k)
	end)
end

X.detour = function(name, func)
	for _, o in next, g(true) do
		if type(o) == "function" and islclosure(o) then
			local i = d.getinfo(o)
			if i.name == name or (i.source and i.source:find(name)) then
				hookfunction(o, func)
			end
		end
	end
end

X.inject_module = function(m_name, patch_tbl)
	for _, o in next, g(true) do
		if type(o) == "table" then
			local i = d.getinfo(o)
			if i.source and i.source:find(m_name) then
				for k, v in next, patch_tbl do rawset(o, k, v) end
			end
		end
	end
end

X.force_loop = function(manifest)
	rs.Heartbeat:Connect(function()
		for k, v in next, manifest do
			X.extreme(k, v)
		end
	end)
end

X.silent_hit = function(remote_name, power)
	X.detour(remote_name, function(old, ...)
		local args = {...}
		local lp = pls.LocalPlayer
		local t = nil
		local md = 1000
		for _, p in next, pls:GetPlayers() do
			if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d_m = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
				if d_m < md then md = d_m t = p end
			end
		end
		if t then
			for i = 1, (power or 10) do
				old(args[1], t.Character.HumanoidRootPart, t.Character.Humanoid)
			end
		end
		return old(unpack(args))
	end)
end

X.dump = function(k)
	for _, o in next, g(true) do
		if type(o) == "table" and rawget(o, k) ~= nil then
			print(t_str(o))
		end
	end
end

return X
