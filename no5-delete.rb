#! /usr/bin/ruby1.8

require '/home/many/NumberFive/lib/rbmediawiki'
require '/home/many/NumberFive/.conf/credentials'

# Sieht komplizierter aus als es ist.

wiki = Api.new(nil, nil, WIKI_USER, WIKI_SERVER, WIKI_APIURL)
wiki.login(WIKI_PASSWORD)

exceptions = [ "Kategorie:URV", "Vorlage:Schnelllöschen" ]

timeStart = Time.now - (14 * 24 * 60 * 60)
timeStartstring = timeStart.strftime("%Y-%m-%dT%H:%M:%SZ")

toDelete = wiki.query_list_categorymembers(:cmtitle => "Kategorie:Löschen", 
	:cmlimit => 100, :cmprop => "timestamp|ids|title", :cmsort => "timestamp", 
	:cmdir => "desc", :cmstart => timeStartstring)

deleted = 0
cm = toDelete["query"]["categorymembers"]
if cm.empty?
	exit 0
end

begin
  loeschlog = Page.new("Benutzer:NumberFive/Loeschprotokoll", wiki)
  loeschtext = ""
  cm["cm"].each do |cm|
    if cm.is_a?(Hash) and ! exceptions.include?(cm["title"])
      page = Page.new(cm["title"], wiki)
      content = page.get
      loeschtext = loeschtext + "<br/> [[" + cm["title"] + "]]: " + 
      content["content"].match(/.*\{\{L..?schen\|(.*?)\}\}.*/)[1]
      page.delete("Automatische Loeschung nach 14 Tagen per " +
        "[[Benutzer:NumberFive/Loeschbot]]")
    end

    deleted = deleted + 1
    if deleted > 50
      exit 0
    end
  end

ensure
  if loeschtext != ""
    loeschtext = "\n== " + Time.now.to_s + " == \n" + loeschtext
    loeschlog.append(loeschtext, "Loeschlog", false, true)
  end
end
