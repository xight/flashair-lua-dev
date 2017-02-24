require("flashair")

describe("flashair", function()
	local config = {}
	local lyaml
	local download_file1,download_file2

	setup(function()
		download_file1 = "__test_download1"
		download_file2 = "__test_download2"
		lyaml = require("lyaml")
		local fh, msg = io.open("config.yaml","r")

		if fh then
			local data = fh:read("*a")
			config = lyaml.load(data)
		end
	end)

	teardown(function()
		os.remove(download_file1)
		os.remove(download_file2)
	end)

	it("check request (srequest)", function()
		local b, c, h = fa.request("http://example.com/")
		assert.are.equals(c, 200)
	end)

	it("check request (srequest / not found)", function()
		local b, c, h = fa.request("http://example.com/not-exist")
		assert.are.equals(c, 404)
	end)

	it("check request (srequest / not exist domain)", function()
		local b, c, h = fa.request("http://not-exist.com/")
		assert.are.equals(c, 'host or service not provided, or not known')
	end)

	it("check request (trequest)", function()
		local b, c, h = fa.request{url = "http://example.com/"}
		assert.are.equals(c, 200)
	end)

	it("check request (trequest / not found)", function()
		local b, c, h = fa.request{url = "http://example.com/not-exist"}
		assert.are.equals(c, 404)
	end)

	it("check request (trequest / not exist domain)", function()
		local b, c, h = fa.request{url = "http://not-exist.com/"}
		assert.are.equals(c, 'host or service not provided, or not known')
	end)

	it("check HTTPGetFile", function()
		local state = fa.HTTPGetFile("http://example.com/",download_file1)
		assert.are.equals(state, 1)
	end)

	it("check HTTPGetFile (not exist file)", function()
		local state = fa.HTTPGetFile("http://example.com/not-exist",download_file2)
		assert.are.equals(state, nil)
	end)

	it("check HTTPGetFile (not exist domain)", function()
		local state = fa.HTTPGetFile("http://not-exist.com/",download_file2)
		assert.are.equals(state, nil)
	end)

	it("check pio", function()
		local ctrl = 1
		local data = 1
		fa.pio(ctrl, data)
		assert.are.equals(1,1)
	end)

	it("check md5", function()
		local md5_a = fa.md5("a")
		local md5_KNOWN_a = "0cc175b9c0f1b6a831c399e269772661"
		assert.are.equals(md5_a, md5_KNOWN_a)
	end)

	it("check hash (md5)", function()
		local md5_a = fa.hash("md5","flashair")
		local md5_KNOWN_a = "ee626b402376f878d0de4a7a81df7675"
		assert.are.equals(md5_a, md5_KNOWN_a)
	end)

	it("check hash (sha1)", function()
		local md5_a = fa.hash("sha1","flashair")
		local md5_KNOWN_a = "c7b0cbd0e25e56f5e15e3aba767e816ff025b26c"
		assert.are.equals(md5_a, md5_KNOWN_a)
	end)

	it("check hash (sha256)", function()
		local md5_a = fa.hash("sha256","flashair")
		local md5_KNOWN_a = "6594b08c58521f2ff8dd9f608fe355b5e24067b38556216486a13939070ffb86"
		assert.are.equals(md5_a, md5_KNOWN_a)
	end)

	it("check hash (hmac-sha256)", function()
		local md5_a = fa.hash("hmac-sha256","flashair","secret")
		local md5_KNOWN_a = "0d201feddd40baa509230859e1b85ed173170d099c2e6c3babad2b6efc6aa400"
		assert.are.equals(md5_a, md5_KNOWN_a)
	end)

	it("check sleep", function()
		local sleep_sec = 1
		local t = os.time()
		fa.sleep(sleep_sec * 1000)
		local t2 = os.time()
		assert.are.equals(t2 - t, sleep_sec)
	end)

	-- fa.sharedmemory(command, addr, len, wdata)
	-- https://flashair-developers.com/ja/documents/api/lua/reference/#sharedmemory
	it("check sharedmemory (write)", function()
		local ret = fa.sharedmemory("write", 0, 8, "flashair")
		assert.are.equals(ret, 1)
	end)

	it("check sharedmemory (read)", function()
		local ret = fa.sharedmemory("read", 0, 8, 0)
		assert.are.equals(ret, "flashair")
	end)

	it("check sharedmemory (write 2)", function()
		local ret = fa.sharedmemory("write", 1, 8, "flashair")
		assert.are.equals(ret, 1)
	end)

	it("check sharedmemory (read 2)", function()
		local ret = fa.sharedmemory("read", 0, 9, 0)
		assert.are.equals(ret, "fflashair")
	end)

	--[[
	it("check sharedmemory (write fail : addr < 0)", function()
		local ret = fa.sharedmemory("write", -1, 8, "flashair")
		assert.are.equals(ret, nil)
	end)

	it("check sharedmemory (write fail : addr > 511)", function()
		local ret = fa.sharedmemory("write", 0, 8, "flashair")
		assert.are.equals(ret, nil)
	end)

	it("check sharedmemory (write fail : len < length(wdata))", function()
		local ret = fa.sharedmemory("write", 0, 8, "flashair")
		assert.are.equals(ret, nil)
	end)
	]]

	it("check ReadStatusReg return value length", function()
		local status_reg = fa.ReadStatusReg()
		assert.are.equals(string.len(status_reg), 240)
	end)

	it("check ReadStatusReg ip address", function()
		local ip = config.ip_address
		local ip_hex = string.sub(fa.ReadStatusReg(),161,168)
		ip1 = tonumber(string.sub(ip_hex,1,2),16)
		ip2 = tonumber(string.sub(ip_hex,3,4),16)
		ip3 = tonumber(string.sub(ip_hex,5,6),16)
		ip4 = tonumber(string.sub(ip_hex,7,8),16)
		local ret_ip = ip1 .. "." .. ip2 .. "." .. ip3 .. "." .. ip4
		assert.are.equals(ret_ip , ip)
	end)

	it("check GetScanInfo", function()
		local ssid = config.ssid
		local ret_ssid, ret_other = fa.GetScanInfo(0)
		assert.are.equals(ssid,ret_ssid)
	end)
end)
