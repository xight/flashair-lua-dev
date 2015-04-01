# flashair-lua-dev

FlashAir独自のLua関数を利用するためのライブラリ。  
このライブラリが提供するオブジェクト fa が FlashAir の fa の様に振る舞うため、FlashAir外でも開発が可能になる。

* master: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=master)](https://travis-ci.org/xight/flashair-lua-dev)
* develop: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=develop)](https://travis-ci.org/xight/flashair-lua-dev)

# Usage

```lua
require("flashair")

local b, c, h = fa.request("http://example.com/")
print(b)

local b, c, h = fa.request{url = "http://example.com/"}
print(b)
```

# Requirement

* [luasocket](https://github.com/diegonehab/luasocket)
* [luacrypto](https://github.com/mkottman/luacrypto)
* [lyaml](https://github.com/gvvaughan/lyaml)
* [busted](https://github.com/Olivine-Labs/busted) for unit testing

# ToDo

* fa.pio の仕様確認と実装
* fa.ReadStatusReg()の仕様確認と実装
* fa.FTP の実装

# Reference

* [FlashAir Developers - Lua Reference](https://www.flashair-developers.com/ja/documents/api/lua/reference/)

# License

Copyright (c) 2015 Yoshiki Sato  
Released under the MIT license  
https://github.com/xight/flashair-lua-dev/blob/master/LICENSE
