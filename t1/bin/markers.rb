#!/usr/bin/env ruby
# vim: set ts=4 sw=4 ai sta:

# markers.rb
#   Simple script to filter the list of markers.

require 'rubygems'

require 'json'

text = File.read 'markers.js'
js = JSON.parse(text.gsub(/^[^=]*=/, '{"markers":') + '}')

print "Total markers: #{js["markers"].length}\n"

filtered = []
js["markers"].each do |mark|
	msg = mark["msg"]

	next if msg =~ /\A\s*\Z/

	filtered.push mark
end

print "After filtering: #{filtered.length}\n"

File.open 'markers-filtered.js', 'w' do |file|
	file.write 'var markerData='
	file.write filtered.to_json
	file.write "\n"
end

