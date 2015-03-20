--[[
flashair-lua-dev
http://github.com/xight/flashair-lua-dev
]]

FlashAir = {}
FlashAir.new = function()
	local socket = require("socket")
	local obj = {}
	local base = _G

	local lyaml = require("lyaml")
	local fh, msg = io.open("config.yaml","r")

	if fh then
		local data = fh:read("*a")
		obj.config = lyaml.load(data)
	end

	-- b, c, h = fa.request(url [, method [, headers [, file [, body [, bufsize [, redirect]]]]]])
	local srequest = function(url, ...)
		local param = ...
		local method   = nil
		local headers  = nil
		local file     = nil
		local body     = nil
		local bufsize  = nil
		local redirect = nil
		if param ~= nil then
			method   = param[1]
			headers  = param[2]
			file     = param[3]
			body     = param[4]
			bufsize  = param[5]
			redirect = param[6]
		end

		local http = require("socket.http")
		local ltn12 = require("ltn12")

		local body = {}
		local b, c, h = http.request {
			url = url,
			sink = ltn12.sink.table(body),
			method = method,
			headers = headers,
			source = nil, 
			step = nil,
			proxy = nil, 
			redirect = redirect,
			create = nil,
		}
		return table.concat(body), c, h
	end

	local trequest = function(...)
		local param = ...
		local url      = param["url"]
		local method   = param["method"]
		local headers  = param["headers"]
		local file     = param["file"]
		local body     = param["body"]
		local bufsize  = param["bufsize"]
		local redirect = param["redirect"]

		local http = require("socket.http")
		local ltn12 = require("ltn12")

		local body = {}
		local b, c, h = http.request {
			url = url,
			sink = ltn12.sink.table(body),
			method = method,
			headers = headers,
			source = nil, 
			step = nil,
			proxy = nil, 
			redirect = redirect,
			create = nil,
		}
		return table.concat(body), c, h
	end

	obj.request = socket.protect(function(reqt, body)
		if base.type(reqt) == "string" then return srequest(reqt, body)
		else return trequest(reqt) end
	end)

	obj.HTTPGetFile = function(uri, filepath, ...)
		local param = {...}

		local socket_url = require("socket.url")
		local parsed_url = socket_url.parse(uri)
		local user = param[1] 
		local pass = param[2] 

		if (user ~= nil and pass ~= nil) then
			local url = socket_url.parse(uri)
			local parsed_url = socket_url.parse(uri)
			parsed_url.user = user
			parsed_url.password = pass
			uri = socket_url.build(parsed_url)
		end

		local http = require("socket.http")
		local ltn12 = require("ltn12")

		-- get HTTP status code
		local b, c, h = http.request {
			url = uri,
		}

		local ret = nil
		if c == 200 then
			ret = 1

			local b, c, h = http.request {
				url = uri,
				sink = ltn12.sink.file(io.open(filepath,"w")),
			}
		end

		return ret
	end

	obj.pio = function(ctrl, data)
		-- ad hoc
		local s = 1
		local indata = 1
		return s, indata
	end

	obj.FTP = function(cmd, uri, filename)
	end

	obj.md5 = function(str)
		return require("crypto").digest("md5", str)
	end

	-- count = fa.Scan([ssid])
	obj.Scan = function(...)
		local count = 1
		return count
	end

	-- ssid, other = fa.GetScanInfo(num)
	obj.GetScanInfo = function(num)
		local ssid = obj.config.ssid
		local other = {}
		return ssid, other
	end

	obj.Connect = function(ssid, networkkey)
		io.stderr:write("Connect: " .. ssid .. ", " .. networkkey .. "\n")
	end

	obj.Establish = function(ssid, networkkey, encmode)
		io.stderr:write("Establish: " .. ssid .. ", " .. networkkey .. ", " ..encmode  .. "\n")
	end

	obj.Bridge = function(ssid, networkkey, encmode, brgssid, brgnetworkkey)
		io.stderr:write("Bridge: " .. ssid .. ", " .. networkkey .. ", " ..encmode)
		io.stderr:write(brgssid .. ", " .. brgnetworkkey .. "\n")
	end

	obj.Disconnect = function()
		io.stderr:write("Disconnect\n")
	end

	obj.sleep = function(msec)
		local sec = msec / 1000
		os.execute("sleep ".. sec)
	end

	obj.ReadStatusReg = function()
		--[[
		ssid            -- 17-56  (535349440000...00)
		mac_address     -- 97-108 (123456ABCDEF)
		ip_address      -- 161-168 (c0a802fa)
		subnet_mask     -- 169-176 (ffffffff)
		default_gateway -- 177-184 (c0a80201)
		preferred_dns   -- 185-192 (c0a80201)
		alternate_dns   -- 193-200 (00000000)
		]]
		-- split
		local split_it = function(str, sep)
			if str == nil then return nil end
			assert(type(str) == "string", "str must be a string")
			assert(type(sep) == "string", "sep must be a string")
			return string.gmatch(str, "[^\\" .. sep .. "]+")
		end
		local split = function(str, sep)
			local ret = {}
			for seg in split_it(str, sep) do
				ret[#ret+1] = seg
			end
			return ret
		end

		-- hex generate
		local ip2hex = function(ip)
			local ip_t = split(ip,".")
			local ip_hex = ""
			for i,v in ipairs(ip_t) do
				ip_hex = ip_hex .. string.format("%02x",v)
			end
			return ip_hex
		end

		local mac2hex = function(mac)
			local mac_t = split(mac,":")
			return table.concat(mac_t,"")
		end

		local ssid2hex = function(ssid)
			local ssid_hex = ""
			for i = 1, string.len(ssid) do
				ssid_hex = ssid_hex .. string.format("%02x",string.byte(ssid,i))
			end
			-- zero padding (size 64)
			for i = 1, 64 - string.len(ssid_hex) do
				ssid_hex = ssid_hex .. "0"
			end
			return ssid_hex
		end

		--            1-------------16
		local ret  = "000000000000a000"
		--            17-80 (64byte)
		ret = ret .. ssid2hex(obj.config.ssid)
		--            81------------96
		ret = ret .. "06640b0000000000"
		--            97-108 (12byte)
		ret = ret .. mac2hex(obj.config.mac_address)
		--            109----------------------------------------------160
		ret = ret .. "0000000000000000000000000000000000000000000000000000"
		--            161-200
		ret = ret .. ip2hex(obj.config.ip_address)
		ret = ret .. ip2hex(obj.config.subnet_mask)
		ret = ret .. ip2hex(obj.config.default_gateway)
		ret = ret .. ip2hex(obj.config.preferred_dns)
		ret = ret .. ip2hex(obj.config.alternate_dns)
		--            201----------------------------------240
		ret = ret .. "0000000000000000000000000000000000000000"
		return ret
	end

	return obj
end

fa = FlashAir.new()
