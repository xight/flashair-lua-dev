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

	obj._network = {}
	if fh then
		local data = fh:read("*a")
		obj.config = lyaml.load(data)

		if obj.config.ip_address ~= nil then
			obj._network.ip_address = obj.config.ip_address
		end
		if obj.config.subnet_mask ~= nil then
			obj._network.subnet_mask = obj.config.subnet_mask
		end
		if obj.config.default_gateway ~= nil then
			obj._network.default_gateway = obj.config.default_gateway
		end
	end

	-- b, c, h = fa.request(url [, method [, headers [, file [, body [, bufsize [, redirect]]]]]])
	local srequest = function(url, ...)
		local param = ...
		local method   = nil
		local headers  = nil
		local file     = nil
		local reqbody  = nil
		local bufsize  = nil
		local redirect = nil
		if param ~= nil then
			method   = param[1]
			headers  = param[2]
			file     = param[3]
			reqbody  = param[4]
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
			source = ltn12.source.string(reqbody),
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
		local reqbody  = param["body"]
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
			source = ltn12.source.string(reqbody), 
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

	-- not implement
	obj.FTP = function(cmd, uri, filename)
	end

	-- md5 = fa.md5(str)
	-- obsolete (< 3.0.0)
	obj.md5 = function(str)
		return obj.hash("md5", str)
	end

	-- hash = fa.hash(name, data, key)
	obj.hash = function(name, data, key)
		local function tohex(s)
			return (string.gsub(s, ".", function (c)
				return string.format("%.2x", string.byte(c))
			end))
		end -- tohex

		ret = nil

		if (name == "md5") then
			ret = tohex(require"openssl.digest".new("md5"):final(data))
		elseif (name == "sha1") then
			ret = tohex(require"openssl.digest".new("sha1"):final(data))
		elseif (name == "sha256") then
			ret = tohex(require"openssl.digest".new("sha256"):final(data))
		elseif (name == "hmac-sha256") then
			ret = tohex(require"openssl.hmac".new("secret","sha256"):final(data))
		end
		return ret
	end

	-- obsolete (using LuaCrypto)
	obj._hash = function(name, data, key)
		local crypto = require("crypto")
		ret = nil
		if (name == "md5") then
			ret = crypto.digest("md5", data)
		elseif (name == "sha1") then
			ret = crypto.digest("sha1",data)
		elseif (name == "sha256") then
			ret = crypto.digest("sha256",data)
		elseif (name == "hmac-sha256") then
			ret = crypto.hmac.digest("sha256",data, key)
		end
		return ret
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

	-- fa.sharedmemory(command, addr, len, wdata)
	obj._sharedmemory = {}

	obj.sharedmemory = function(command, addr, len, wdata)
		assert(command == "read" or command == "write", "command must be a \"write\" or \"read\"")
		assert(type(addr) == "number", "addr must be a number")
		assert(type(len) == "number", "len must be a number")

		ret = nil


		if command == "write" then
			wdata_t = {}
			wdata:gsub(".",function(c) table.insert(wdata_t,c) end)

			j = 1
			for i = addr + 1, addr + len  do
				-- print(i, j, wdata_t[j])
				obj._sharedmemory[i] = wdata_t[j]
				j = j + 1
			end
			ret = 1

		elseif command == "read" then
			ret = ""
			for i = addr + 1, addr + len do
				-- print(i, obj._sharedmemory[i])
				if obj._sharedmemory[i] == nil then
					obj._sharedmemory[i] = " "
				end
				ret = ret .. obj._sharedmemory[i]
			end
		end
		return ret
	end

	-- fa.SetCert(filename)
	-- not implement
	obj.SetCert = function(filename)
		return 1
	end

	-- fa.strconvert(format, orgstr)
	-- not implement
	obj.strconvert = function(format, orgstr)
		assert(format == "sjis2utf8" or format == "utf82sjis", "format must be a \"sjis2utf8\" or \"utf82sjis\"")
		return nil
	end

	-- fa.SetChannel(channelNo)
	-- not implement
	obj.SetChannel = function(channelNo)
		assert(type(channelNo) == "number", "channelNo must be a number")
	end

	-- fa.MailSend(from,headers,body,server,user,password, attachment, ContentType)
	-- not implement
	obj.MailSend= function(from,headers,body,server,user,password, attachment, ContentType)
		local success_message = "MailSend is success."
		local failure_message = "Error: It filed to send."
		return success_message
	end

	-- fa.spi(command, data)
	-- not implement
	obj.spi = function(command, data)
		assert(command == "init" or command == "mode" or command == "bit" or command == "write" or command == "read" or command == "cs", "command must be a \"init\", \"mode\", \"bit\", \"write\", \"read\" or \"cs\"")
		return 1
	end

	obj.ReadStatusReg = function()
		--[[
		ssid            -- 17-80  (535349440000...00)
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

	-- ip, mask, gw = fa.ip(ipaddress, subnetmask, gateway)
	obj.ip = function(ipaddress, subnetmask, gateway)
		if ipaddress ~= nil then
			obj._network.ip_address = ipaddress
		end
		if subnetmask ~= nil then
			obj._network.subnet_mask = subnetmask
		end

		if gateway ~= nil then
			obj._network.default_gateway = gateway
		end

		return obj._network.ip_address, obj._network.subnet_mask, obj._network.default_gateway
	end

	-- result = fa.WlanLink()
	-- not implement
	obj.WlanLink = function()
		local connected = 1
		local disconnect = 0
		return connected
	end

	-- fa.remove(filename)
	-- not implement
	obj.remove = function(filename)
	end

	-- fa.rename(oldfile, newfile)
	-- not implement
	obj.rename= function(oldfile, newfile)
	end

	-- res, data1, data2, data3, ... = fa.i2c(table)
	-- not implement
	obj.i2c = function(table)
	end
	
	-- result, filelist, time = fa.search(type, path, searchtime)
	-- not implement
	obj.search = function(type, path, searchtime)
	end

	-- result = fa.control("time"[, savetime])
	-- result = fa.control("time"[, savetime])
	-- result = fa.control("fioget")
	-- result = fa.control("fioset", enable)
	-- not implement
	obj.control= function(arg, val)
	end

	-- cnt,tbl = fa.ConnectedSTA()
	-- not implement
	obj.ConnectedSTA = function()
	end
	
	-- res, type, payload = fa.websocket(table)
	-- not implement
	obj.websocket = function(table)
	end

	return obj
end

fa = FlashAir.new()
