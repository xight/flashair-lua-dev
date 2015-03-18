require("flashair")

describe("flashair", function()
	local download_file1 = "__test_download1"
	local download_file2 = "__test_download2"

	it("check request", function()
		local b, c, h = fa.request("http://example.com/")
		assert.are.equals(c, 200)
	end)

	it("check request (not found)", function()
		local b, c, h = fa.request("http://example.com/not-exist")
		assert.are.equals(c, 404)
	end)

	it("check request (not exist domain)", function()
		local b, c, h = fa.request("http://not-exist.com/")
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

	it("check sleep", function()
		local sleep_sec = 1
		local t = os.time()
		fa.sleep(sleep_sec * 1000)
		local t2 = os.time()
		assert.are.equals(t2 - t, sleep_sec)
	end)

	it("check ReadStatusReg return value length", function()
		local status_reg = fa.ReadStatusReg()
		assert.are.equals(string.len(status_reg), 240)
	end)

	it("check ReadStatusReg ip address", function()
		local ip = "192.168.2.250"
		local ip_hex = string.sub(fa.ReadStatusReg(),161,168)
		ip1 = tonumber(string.sub(ip_hex,1,2),16)
		ip2 = tonumber(string.sub(ip_hex,3,4),16)
		ip3 = tonumber(string.sub(ip_hex,5,6),16)
		ip4 = tonumber(string.sub(ip_hex,7,8),16)
		local ret_ip = ip1 .. "." .. ip2 .. "." .. ip3 .. "." .. ip4
		assert.are.equals(ret_ip , ip)
	end)

	teardown(function()
		os.remove(download_file1)
		os.remove(download_file2)
	end)
end)
