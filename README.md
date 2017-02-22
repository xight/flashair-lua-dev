# flashair-lua-dev

FlashAir独自のLua関数を利用するためのライブラリ。  
このライブラリが提供するオブジェクト fa が FlashAir の fa の様に振る舞うため、FlashAir外でも開発が可能になる。

* master: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=master)](https://travis-ci.org/xight/flashair-lua-dev)
* develop: [![Build Status](https://travis-ci.org/xight/flashair-lua-dev.svg?branch=develop)](https://travis-ci.org/xight/flashair-lua-dev)

# Install

## Install lua library

    % luarocks install luasocket
    % luarocks install luaossl
    % luarocks install lyaml
    % luarocks install busted

## git clone & testing

    % git clone https://github.com/xight/flashair-lua-dev
    % cd flashair-lua-dev
    % busted spec

## Run sample script

    % lua sample.lua

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
* ~~[luacrypto](https://github.com/mkottman/luacrypto)~~ (deprecated)
* [luaossl](http://25thandclement.com/~william/projects/luaossl.html)
* [lyaml](https://github.com/gvvaughan/lyaml)
* [busted](https://github.com/Olivine-Labs/busted) for unit testing

# ToDo

* fa.pio の仕様確認と実装
* fa.ReadStatusReg()の仕様確認と実装
* fa.FTP の実装

# Reference

* [FlashAir Developers - Lua Reference](https://www.flashair-developers.com/ja/documents/api/lua/reference/)
* [SlideShare - xightorg - 2015-03-21 FlashAir 進捗報告会](http://www.slideshare.net/xightorg/2015-0321-flashair)

# License

Copyright (c) 2017 Yoshiki Sato  
Released under the MIT license  
https://github.com/xight/flashair-lua-dev/blob/master/LICENSE
