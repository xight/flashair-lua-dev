--[[
flashair-lua-dev
http://github.com/xight/flashair-lua-dev
]]

FlashAir = {}
FlashAir.new = function()
	local obj = {}

	-- b, c, h = fa.request(url [, method [, headers [, file [, body [, bufsize [, redirect]]]]]])
	obj.request = function(...)
		local param = ...
		local url      = param["url"]
		local method   = param["methd"]
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

	obj.HTTPGetFile = function(uri, filepath, ...)
		local param = {...}

		local parsed_url = require("socket.url").parse(uri)
		local user = param[1] 
		local pass = param[2] 

		if (user ~= nil and pass ~= nil) then
			local url = require("socket.url").parse(uri)
			local parsed_url = require("socket.url").parse(uri)
			parsed_url.user = user
			parsed_url.password = pass
			uri = require("socket.url").build(parsed_url)
		end

		local http = require("socket.http")
		local ltn12 = require("ltn12")

		-- get HTTP status code
		local b, c, h =  http.request {
			url = uri,
		}

		local ret = nil
		if c == 200 then
			ret = 1

			local b, c, h =  http.request {
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
		local ssid = "DUMMY_SSID"
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
		local ssid            = "SSID"              -- 17-56  (535349440000...00)
		local mac_address     = "12:34:56:AB:CD:EF" -- 97-108 (123456ABCDEF)
		local ip_address      = "192.168.2.250"     -- 161-168 (c0a802fa)
		local subnet_mask     = "255.255.255.0"     -- 169-176 (ffffffff)
		local default_gateway = "192.168.2.1"       -- 177-184 (c0a80201)
		local preferred_dns   = "192.168.2.1"       -- 185-192 (c0a80201)
		local alternate_dns   = "0.0.0.0"           -- 193-200 (00000000)

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
			-- zero padding (size 50)
			for i = 1, 50 - string.len(ssid_hex) do
				ssid_hex = ssid_hex .. "0"
			end
			return ssid_hex
		end

		--            1-------------16
		local ret  = "000000000000a000"
		--            17-56 (50byte)
		ret = ret .. ssid2hex(ssid)
		--            57--------------------------96
		ret = ret .. "0000000000000006640b0000000000"
		--            97-108 (12byte)
		ret = ret .. mac2hex(mac_address)
		--            109----------------------------------------------160
		ret = ret .. "0000000000000000000000000000000000000000000000000000"
		--            161-200
		ret = ret .. ip2hex(ip_address)
		ret = ret .. ip2hex(subnet_mask)
		ret = ret .. ip2hex(default_gateway)
		ret = ret .. ip2hex(preferred_dns)
		ret = ret .. ip2hex(alternate_dns)
		--            201----------------------------------240
		ret = ret .. "0000000000000000000000000000000000000000"
		return ret
	end

	return obj
end

fa = FlashAir.new()
