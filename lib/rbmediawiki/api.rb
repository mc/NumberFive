#coding: utf-8

Ourconfig = YAML::load(File.open(File.dirname(__FILE__)+"/config.yml"))

# This class provides an interface for the MediaWiki API.
# Methods match specific queries to the API, and so the meaning of the 
# parameters are described in http://www.mediawiki.org/wiki/API
#
# It is intended to be used as a base layer to build specific methods on top 
# of it
#
# Only four methods are special and deserve comments here: #new, #login, #query and #add_post
class Api

	QUERY = [:titles, :pageid, :revids, :redirects, :indexpageids, :export, :exportnowrap]
	MY_API = { 
		"unblock" => [:id, :user, :token, :gettoken, :reason],
		"import"  => [:token, :summary, :xml, :interwikisource, :interwikipage, :fullhistory, :templates, :namespace],
		"undelete" => [:title, :token, :reason, :timestamps],
		"emailuser" => [:target, :subject, :text, :token, :ccme],
		"block" => [:user, :token, :gettoken, :expiry, :reason, :anononly, :nocreate, :autoblock, :noemail, :hidename, :allowusertalk, :reblock],
		"paraminfo" => [:modules, :querymodules, :mainmodule, :pagesetmodule],
		"move" => [:from, :fromid, :to, :token, :reason, :movetalk, :movesubpages, :noredirect, :watch, :unwatch],
		"rollback" => [:title, :user, :token, :summary, :markbot],
		"feedwatchlist" => [:feedformat, :hours, :allrev],
		"patrol" => [:token, :rcid], 
		"watch" => [:title, :unwatch],
		"protect" => [:title, :token, :protections, :expiry, :reason, :cascade, :watch],
		"edit" => [:title, :section, :text, :token, :summary, :minor, :notminor, :bot, :basetimestamp, :starttimestamp, :recreate, 
			:createonly, :nocreate, :captchaword, :captchaid, :watch, :unwatch, :md5, :prependtext, :appendtext,:undo, :undoafter],
		"parse" => [:title, :text, :page, :redirects, :oldid, :prop, :pst, :onlypst],
		"expandtemplates" => [:title, :text, :generatexml],
		"delete" => [:title, :pageid, :token, :reason, :watch, :unwatch, :oldimage],
		"purge" => [:titles],

		"query_prop_categories"  => [:clprop, :clshow, :cllimit, :clcontinue, :clcategories] << QUERY,
		"query_prop_images"      => [:imlimit, :incontinue] << QUERY,
		"query_prop_revisions"   => [:rvprop, :rvlimit, :rvstartid, :rvendid, :rvstart, :rvend, :rvdir, :rvuser, :rvexcludeuser, :rvexpandtemplates, 
			:rvgeneratexml, :rvsection, :rvtoken, :rvcontinue, :rvdiffto] << QUERY, 
		"query_prop_imageinfo"   => [:iiprop, :iilimit, :iistart, :iiend, :iiurlwidth, :iiurlheight, :iicontinue] << QUERY,
		"query_prop_duplicatefiles" => [:dflimit, :dfcontinue] << QUERY,
		"query_prop_extlinks"    => [:ellimit, :eloffset] << QUERY,
		"query_prop_info"        => [:inprop, :intoken, :incontinue] << QUERY,
		"query_prop_templates"   => [:tlnamespace, :tllimit, :tlcontinue] << QUERY,
		"query_prop_links"       => [:plnamespace, :pllimit, :plcontinue] << QUERY,
		"query_prop_categoryinfo" => [:cicontinue] << QUERY,
		"query_prop_langlinks"   => [:lllimit, :llcontinue] << QUERY,

		"query_list_exturlusage" => [:euprop, :euoffset, :euprotocol, :euquery, :eunamespace, :eulimit] << QUERY,
		"query_list_allpages"    => [:apfrom, :apprefix, :apnamespace, :apfilterredir, :apminsize, :apmaxsize, 
			:apprtype, :apprlevel, :apprfiltercascade, :aplimit, :apdir, :apfilterlanglinks] << QUERY,
		"query_list_protectedtitles" => [:ptnamespace, :ptlevel, :ptlimit, :ptdir, :ptstart, :ptend, :ptprop] << QUERY,
		"query_list_deletedrevs" => [:drstart, :drend, :drdir, :drfrom, :drcontinue, :drunique, :druser, :drexcludeuser, :drnamespace, :drlimit, :drprop] << QUERY,
		"query_list_blocks"      => [:bkstart, :bkend, :bkdir, :bkids, :bkusers, :bklimit, :bkprop] << QUERY,
		"query_list_alllinks"    => [:alcontinue, :alfrom, :alprefix, :alunique, :alprop, :alnamespace, :allimit] << QUERY,
		"query_list_random"      => [:rnnamespace, :rnlimit, :rnredirect] << QUERY,
		"query_list_categorymembers" => [:cmtitle, :cmprop, :cmnamespace, :cmcontinue, :cmlimit, :cmsort, :cmdir, :cmstart, :cmend, :cmstartsortkey, :cmendsortkey] << QUERY,
		"query_list_alluser"     => [:aufrom, :auprefix, :augroup, :auprop, :aulimit, :auwitheditsonly] << QUERY,
		"query_list_watchlist"   => [:wlallrev, :wlstart, :wlend, :wlnamespace, :wldir, :wllimit, :wlprop, :wlshow] << QUERY,
		"query_list_search"      => [:srsearch, :srnamespace, :srwhat, :srredirects, :sroffset, :srlimit] << QUERY,
		"query_list_embeddedin"  => [:eititle, :eicontinue, :einamespace, :eifilterredir, :eilimit] << QUERY,
		"query_list_globalblocks" => [:bgstart, :bgend, :bgdir, :bgids, :bgaddresses, :bgip, :bglimit, :bgprop] << QUERY,
		"query_list_watchlistraw" => [:wrcontinue, :wrnamespace, :wrlimit, :wrprop, :wrshow] << QUERY,
		"query_list_usercontribs" => [:uclimit, :ucstart, :ucend, :uccontinue, :ucuser, :ucuserprefix, :ucdir, :ucnamespace, :ucprop, :ucshow] << QUERY,
		"query_list_logevents"    => [:leprop, :letype, :lestart, :leend, :ledir, :leuser, :letitle, :lelimit] << QUERY,
		"query_list_backlinks"    => [:bltitle, :blcontinue, :blnamespace, :blfilterredir, :bllimit, :blredirect] << QUERY,
		"query_list_allcategories" => [:acfrom, :acprefix, :acdir, :aclimit, :acprop] << QUERY,
		"query_list_allimages"   => [:aifrom, :aiprefix, :aiminsize, :aimaxsize, :ailimit, :aidir, :aisha1, :aisha1base36, :aiprop] << QUERY,
		"query_list_users"       => [:usprop, :ususers] << QUERY,
		"query_list_recentchanges" => [:rcstart, :rcend, :rcdir, :rcnamespace, :rcprop, :rctoken, :rcshow, :rclimit, :rctype] << QUERY,
		"query_list_imageusage"  => [:iutitle, :iucontinue, :iunamespace, :iufilterredir, :iulimit, :iuredirect] << QUERY,

		"query_meta_siteinfo"    => [:siprop, :sifilteriw, :sishowalldb] << QUERY,
		"query_meta_allmesages"  => [:ammessages, :amfilter, :amlang, :amfrom] << QUERY,
		"query_meta_userinfo"    => [:uiprop] << QUERY,
		}

# * lang: language of the wiki at wikimedia.
# * family: family of the wiki at wikimedia. If the wiki is not language dependant, as commons.wikimedia.org , lang value is ignored.
# * user: user to make the edits
# * server: the url of the server, as in http://en.wikipedia.org this parameter overrides lang and family values
# * api_url: the url of the api, as in http://en.wikipedia.org if not specified, it will be guessed from the lang+family values or the server
    def initialize(lang = nil, family = nil, user = nil, server = nil, api_url = nil)
        @config = Hash.new 
        @config['base_url'] = server
        @config['api_url'] = api_url
        @config['logged'] = false
        @config['user'] = user ? user : Ourconfig['default_user'] 
    end

    def api_url
        return @config['api_url']
    end

    def base_url
        return @config['base_url']
    end

    #Asks for a password and tries to log in. Stores the resulting cookies 
    #for using then when making requests. If the user is already logged iy
    #does nothing

    def login(password = nil)
        if @config['logged']
            return true
        end
        if (!password)
            puts "Introduce password for #{@config['user']} at #{@config['base_url']}"
            password = gets.chomp
        end

        post_me = add_post('lgname',@config['user'])
        post_me = add_post('lgpassword',password, post_me)
        post_me = add_post('action', 'login', post_me)

        login_result = make_request(post_me)

        @config['_session']    = login_result['login']['sessionid']
  	@config['cookieprefix']= login_result['login']['cookieprefix']

        @config['logged'] = true

	if login_result['login']['result'] == "NeedToken"
		post_me = add_post('lgtoken', login_result['login']['token'], post_me)
		login_result = make_request(post_me)
	end

	if login_result['login']['result'] != "Success"
		puts "Something failed authentication:"
		# p login_result
		exit 0
	end

        @config['lgusername']  = login_result['login']['lgusername']
        @config['lguserid']    = login_result['login']['lguserid']
        @config['lgtoken'] 	   = login_result['login']['lgtoken']


        return @cookie
    end

    
	def method_missing(method_id, *splat)
		parms = *splat
		method_name = method_id.id2name

		if ! MY_API[method_name]
			raise 
		end
		
		post = Hash.new
		post_me = Hash.new

		MY_API[method_name].each do |key|
			post[key] = nil
		end

		parms.each do |k, v|
			if post[k].nil?
				post_me = add_post(k.to_s, v, post_me)
			else
				raise "Unknown key #{k} for #{method_name}"
			end
		end

		post_me["action"] = method_name.to_s
		if method_name.to_s =~ /query_prop_(.*)/
			post_me["prop"] = $1
			post_me["action"] = "query"
		elsif method_name.to_s =~ /query_meta_(.*)/
			post_me["meta"] = $1
			post_me["action"] = "query"
		elsif method_name.to_s =~ /query_list_(.*)/
			post_me["list"] = $1
			post_me["action"] = "query"
		end

		post_me = format(post_me, 'xml')
		result = make_request(post_me)
		return result
	end
   
    #method for defining the format. Currently overriden at make_request
    def format(post_me, format = nil)
        post_me = add_post('format', format, post_me)
        return post_me
    end

    #based on rwikibot by Eddie Roger, this method makes a post request to 
    #the api using the values specified at post_this and the cookies obtained
    #during the login (if available)
    #
    #Returns a xml with the result of the query
    def make_request(post_this)
	# puts "Sending:"
	# p post_this
        if !post_this.key?('format') or !post_this['format']
            post_this['format'] = 'xml'
        end

        if @config['logged']
            cookies= "#{@config['cookieprefix']}UserName=#{@config['lgusername']}; #{@config['cookieprefix']}UserID=#{@config['lguserid']}; #{@config['cookieprefix']}Token=#{@config['lgtoken']}; #{@config['cookieprefix']}_session=#{@config['_session']}"
        else
            cookies = ""
        end

        headers =  {
            'User-agent'=>Ourconfig['user-agent'], 
            'Cookie' => cookies
        }
        uri = URI.parse(@config['api_url']) 

        request = Net::HTTP::Post.new(uri.path, headers)
	# p post_this
        request.set_form_data(post_this)
        response = Net::HTTP.new(uri.host, uri.port).start { |http| 
            http.request(request)
        }

        resputf8 = '<?xml version="1.0" encoding="UTF-8" ?>'+response.body[21..-1]

        return_result = XmlSimple.xml_in(resputf8, { 'ForceArray' => false })	
	# puts "Got:"
	# p return_result
        return return_result
    end

    def add_post(key, value, post_me = nil)
        if !post_me
            post_me = Hash.new()
        end
        if value
            post_me[key]=value
        end
        return post_me
    end
end

#code from rwikibot
class Hash
  def to_s
    out = "{"
    self.each do |key, value|
      out += "#{key} => #{value},"
    end
    out = out.chop
    out += "}"
  end
end
