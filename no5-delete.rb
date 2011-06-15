#! /usr/bin/ruby1.8

require '/home/many/wiki.pp/NumberFive/lib/rbmediawiki'
require '/home/many/wiki.pp/NumberFive/.conf/credentials'

# Sieht komplizierter aus als es ist.

# Open Wiki Connection
wiki = Api.new(nil, nil, WIKI_USER, WIKI_SERVER, WIKI_APIURL)
wiki.login(WIKI_PASSWORD)

# These Pages are never deleted
exceptions = [ "Kategorie:URV", "Vorlage:Schnelllöschen" ]

# Calculate DAYS days in seconds and put wiki-compatible time string into var
timeStart = Time.now - (14 * 24 * 60 * 60)
timeStartstring = timeStart.strftime("%Y-%m-%dT%H:%M:%SZ")

# Query the List of pages thats gonna be deleted
toDelete = wiki.query_list_categorymembers(:cmtitle => "Kategorie:Löschen", 
	:cmlimit => 100, :cmprop => "timestamp|ids|title", :cmsort => "timestamp", 
	:cmdir => "desc", :cmstart => timeStartstring)

deleted = 0

# are there actually pages to delete?
cm = toDelete["query"]["categorymembers"]
if cm.empty?
	exit 0
end


begin
  loeschlog = Page.new("Benutzer:NumberFive/Loeschprotokoll", wiki)
  loeschtext = ""

  # iterate through list of categorymembers
  cm["cm"].each do |cm|
    if cm.is_a?(Hash) and ! exceptions.include?(cm["title"])
      page = Page.new(cm["title"], wiki)
      content = page.get
      reason = content["content"].match(/.*\{\{(SLA|(schnell)?L..?schen)\|?(.*?)?\}\}.*/i)

      if reason != nil
          # normalize category
          titel = cm["title"]
	  if cm["title"].match(/^Kategorie:/)
	    titel = ":" + cm["title"]
          end

          # provide a deletion-log
	  if reason[3].nil?
            loeschtext = loeschtext + "<br/> [[#{titel}]]: " + "(Keine Loeschbegruendung angegeben)"
	  else
            loeschtext = loeschtext + "<br/> [[#{titel}]]: " + reason[3]
	  end
        page.delete("Automatische Loeschung nach 14 Tagen per " +
          "[[Benutzer:NumberFive/Loeschbot]]: " + reason[3])
      else
        loeschtext = "<br/> :: [[" + cm["title"] + "]] -- '''Fehler beim Loeschen!"
      end # if reason != nil

    end

    deleted = deleted + 1
    if deleted > 50
      exit 0
    end
  end

ensure
  # in any case, write the log at the wiki
  if loeschtext != ""
    loeschtext = "\n== " + Time.now.to_s + " == \n" + loeschtext
    loeschlog.append(loeschtext, "Loeschlog", false, true)
  end
end
