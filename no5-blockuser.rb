#! /usr/bin/ruby1.8

# Aufruf mit:
# cat | ./no5-blockuser.rb
# Username1
# Username2
# ^D

require '/home/many/wiki.pp/NumberFive/lib/rbmediawiki'
require '/home/many/wiki.pp/NumberFive/.conf/credentials'

# Sieht komplizierter aus als es ist.

# Open Wiki Connection
wiki = Api.new(nil, nil, WIKI_USER, WIKI_SERVER, WIKI_APIURL)
wiki.login(WIKI_PASSWORD)

STDIN.read.split("\n").each do |userName|
	token = wiki.block(:gettoken => true)['block']['blocktoken']
	p wiki.block(:user => userName,
		:token => token,
		:expiry => 'never',
		:reason => 'autoblocked by No5')
end


