#! /usr/bin/ruby1.8

require 'lib/rbmediawiki'
require '.conf/credentials'

wiki = Api.new(nil, nil, WIKI_USER, WIKI_SERVER, WIKI_APIURL)
wiki.login(WIKI_PASSWORD)

exceptions = [ "Kategorie:URV", "Vorlage:Schnelllöschen" ]

timeStart = Time.now - (14 * 24 * 60 * 60)
timeStartstring = timeStart.strftime("%Y-%m-%dT%H:%M:%SZ")

toDelete = wiki.query_list_categorymembers(:cmtitle => "Kategorie:Löschen", 
	:cmlimit => 100, :cmprop => "timestamp|ids|title", :cmsort => "timestamp", 
	:cmdir => "desc", :cmstart => timeStartstring)

deleted = 0
toDelete["query"]["categorymembers"]["cm"].each do |cm|
	if cm.is_a?(Hash) and ! exceptions.include?(cm["title"])
		puts cm["pageid"] + ": " + cm["timestamp"] + " - " + cm["title"]
		token = wiki.query_prop_info(:pageids => cm["pageid"], :intoken => "delete")
		deleteToken = token["query"]["pages"]["page"]["deletetoken"]
		delete = wiki.delete(:pageid => cm["pageid"], :token => deleteToken, 
			:reason => "Automatische Loeschung nach 14 Tagen per [[Benutzer:NumberFive/Loeschbot]]")
		deleted = deleted + 1
	end

	if deleted > 50
		exit 0
	end
end
