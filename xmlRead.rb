require 'rexml/document'
require 'rexml/streamlistener'
include REXML

class MyListener
	include REXML::StreamListener
	def initialize
		super
		@stack = Array.new
		@args = Array.new

		@namespaces = Hash.new
	end

	def tag_start(*args)
		@stack.push(args[0])
		@args.push(args[1])
	
		if (@stack.join(':').match(/^mediawiki:page$/))
			@page = Hash.new
		end
	end

	def text(data)
		if     @stack.join('/') != "mediawiki/page/revision/text" && data =~ /^\s*$/     # whitespace only
			return
		elsif (@stack.join('/') == "mediawiki/siteinfo/namespaces/namespace")
			handle_namespace(@args[3]["key"], data)
		elsif (@stack.join(':').match(/^mediawiki:page:.*/))
			@page[@stack.join(':')] = data
		else
		end
	end

	def tag_end(*args)
		if (@stack.join(':').match(/^mediawiki:page$/))
			handle_page(@page)
		end

		@stack.pop
		@args.pop
	end

	def handle_namespace(key, name)
		@namespaces[key] = name
	end

	def handle_page(page)
		f = File.new('/srv/www/21/150.191.21/ppwp/' + escape_filename(page["mediawiki:page:title"]), 'w+')
		page.each { |key, value|
			f.write(key + "::: " + value)
			f.write("\n")
		}
		f.close
	end

	def escape_filename(fn)
		return fn.gsub(/[^A-Za-z0-9\-_]/, ";")
	end
end


listener = MyListener.new
file = File.new("../Piratenwiki_XMLdump_current_revisions.xml")
Document.parse_stream(file, listener)

