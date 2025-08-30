#!/usr/bin/env ruby
$: << __dir__

CHALLENGES = [
	# ["navigation_optimal", :NavigationOptimal, :NavigationOptimalTest],
	["baked_cookie", :BakedCookie, :BakedCookieTest],
]

CHALLENGES.each { |c|
	name, mod, test = c
	require "lib/#{name}"
	require "test/#{name}"
	mod = Module.const_get mod
	test = Module.const_get test
}
