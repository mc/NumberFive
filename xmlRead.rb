#!/usr/bin/ruby
require 'rexml/document'
require 'rexml/streamlistener'
require 'mysql'

require '.conf/credentials.rb'

include REXML

class String
  require 'iconv' #this line is not needed in rails !
  def to_iso
    Iconv.conv('ISO-8859-1//IGNORE', 'utf-8', self)
  end
end

DUMP='/home/many/PiWi/dump/'
OUT='/home/many/PiWi/dump/out/'

MAPTABLE = {
	"mediawiki:page:id" => "page_id",
	"mediawiki:page:title" => "title",
	"mediawiki:page:revision:contributor:id" => "con_id",
	"mediawiki:page:revision:contributor:username" => "con_name",
	"mediawiki:page:revision:text" => "text",
	"mediawiki:page:revision:comment" => "comment",
	"mediawiki:page:revision:id" => "rev_id",
	"mediawiki:page:revision:timestamp" => "timestamp",
	"mediawiki:page:revision:minor" => "minor",
	"mediawiki:page:redirect" => "redirect"
}

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
	
		if    (@stack.join(':').match(/^mediawiki:page$/))
			@page = Hash.new
		elsif (@stack.join(':').match(/^mediawiki:page:/))
			@page[@stack.join(':')] = 1
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
		#f = File.new(OUT + escape_filename(page["mediawiki:page:title"]), 'w+')
		#page.each { |key, value|
			#f.write(key + "::: " + value)
			#f.write("\n")
		#}
		#f.close
		puts "Working on " + page["mediawiki:page:title"]
		page.delete("mediawiki:page:revision")
		page.delete("mediawiki:page:revision:contributor")
		keys = Array.new
		values = Array.new
		page.each { |k, v|
			keys.push(MAPTABLE[k])
			begin
				values.push("'" + @dbh.escape_string(v.to_s.to_iso) + "'")
				x = v.to_s.to_iso
			rescue
				puts "  -- Page has broken UTF8"
				values.push("'" + @dbh.escape_string(v.to_s) + "'")
			end
		}
		@dbh.query("INSERT INTO articles (" + keys.join(',') + ") VALUES (" + values.join(',') + ")")
	end

	def escape_filename(fn)
		return fn.gsub(/[^A-Za-z0-9\-_]/, ";")
	end

	def set_db(host, user, pass, db)
		@dbh = Mysql.real_connect(host, user, pass, db)

		@dbh.query("DROP TABLE IF EXISTS articles")
		@dbh.query("CREATE TABLE articles 
			(
				id INT auto_increment,
				page_id INT,
				title VARCHAR(255),
				con_id INT,
				con_name VARCHAR(255),
				text TEXT,
				comment VARCHAR(255),
				rev_id INT,
				timestamp DATETIME,
				minor BOOL,
				redirect BOOL,
				KEY(id)
			)
		")
	end
end


listener = MyListener.new
listener.set_db(SQL_HOST, SQL_USER, SQL_PASS, SQL_DB)
file = File.new(DUMP + "Piratenwiki_XMLdump_current_revisions.xml")
Document.parse_stream(file, listener)

