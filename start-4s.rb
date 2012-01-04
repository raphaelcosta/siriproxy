#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'plugins/testproxy/testproxy'
require 'tweakSiri'
require 'siriProxy'

#Also try Eliza -- though it should really not be run "before" anything else.
PLUGINS = [TestProxy]
proxy = SiriProxy.new(PLUGINS, :port => 443, :proxy_4s => true)

#that's it. :-)