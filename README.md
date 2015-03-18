# flashair-lua-dev

FlashAir独自のLua関数を利用するためのライブラリ。

このライブラリが提供するオブジェクト fa が FlashAir の fa の様に振る舞うため、FlashAir外でも開発が可能になる。

* master: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=master)](https://travis-ci.org/xight/flashair-lua-dev)
* develop: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=develop)](https://travis-ci.org/xight/flashair-lua-dev)

# Usage

```lua
require("flashair")

local b, c, h = fa.request("http://example.com/")
```

# Requirement

* [luasocket](https://github.com/diegonehab/luasocket)
* [luacrypto](https://github.com/mkottman/luacrypto/)
* [busted](http://olivinelabs.com/busted/) for unit testing

# ToDo

* fa.request の引数対応
	* method
	* headers
	* file
	* body
	* bufsize
	* redirect
* fa.pio の仕様確認と実装
* fa.ReadStatusReg()の仕様確認と実装
* fa.FTP の実装

# Reference

* [FlashAir Developers - Lua Reference](https://www.flashair-developers.com/ja/documents/api/lua/reference/)

# License

MIT: http://xight.mit-license.org
