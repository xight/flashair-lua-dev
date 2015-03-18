--[[
flashair-lua-dev
http://github.com/xight/flashair-lua-dev
]]

FlashAir = {}
FlashAir.new = function()
	local obj = {}

	-- b, c, h = fa.request(url [, method [, headers [, file [, body [, bufsize [, redirect]]]]]])
	obj.request = function(url, ...)
		local param = {...}
		local method   = param[1] 
		local headers  = param[2] 
		local file     = param[3]
		local body     = param[4]
		local bufsize  = param[5]
		local redirect = param[6]

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

	obj.sleep = function(msec)
		local sec = msec / 1000
		os.execute("sleep ".. sec)
	end

	return obj
end

fa = FlashAir.new()
