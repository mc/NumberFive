#! /usr/bin/ruby1.8

require '/home/many/NumberFive/lib/rbmediawiki'
require '/home/many/NumberFive/irc.rb'
require '/home/many/NumberFive/.conf/credentials.rb'

def irc_send(ircs, item)
	zeile = "%s: %s; . . (%d Bytes) . . %s (%s)" % [item["type"], 
		item["title"], 
		(item["newlen"].to_i - item["oldlen"].to_i), 
		item["user"], item["comment"]]
	ircs.send("%s %s :%s" % ["PRIVMSG", "#piratenpartei.wiki", zeile])
	sleep 1
end

class String
	require 'iconv'
	def to_iso
		Iconv.conv("ISO-8859-1", 'utf-8', self)
	end
end


## irc
irc = IRC.new('irc.freenode.net', 6667, 'PPwikiBot', '#piratenpartei.wiki')

t = Thread.new do
	while true do
		irc.connect
		irc.main_loop
	end
end

sleep 30


## wiki

wiki = Api.new(nil, nil, WIKI_USER, WIKI_SERVER, WIKI_APIURL)

ts = (Time.now.to_i - (10*60))
while true do 
	result = wiki.query_list_recentchanges(
		:rcstart => ts,
		:rcprop => "user|comment|loginfo|title|ids|sizes|redirect",
		:rclimit => 500,
		:rcdir => 'newer'
	)
	rc_array = result["query"]["recentchanges"]["rc"]
	if !rc_array.nil?
		if (rc_array.is_a?(Array))
			rc_array.each do |item|
				irc_send(irc, item)
			end
		else
			irc_send(irc, rc_array)
		end
	end
	ts = Time.now.to_i
	sleep 60
end

exit 0




