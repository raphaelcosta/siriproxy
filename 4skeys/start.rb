#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'plugins/thermostat/siriThermostat'
require 'plugins/testproxy/testproxy'
require 'plugins/eliza/eliza'
require 'tweakSiri'
require 'siriProxy'

#Also try Eliza -- though it should really not be run "before" anything else.
PLUGINS = [TestProxy]
$stdout.puts 'TESTE'
proxy = SiriProxy.new(PLUGINS)

#that's it. :-)
