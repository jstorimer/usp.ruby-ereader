#!/usr/bin/env ruby

# Graciously taken from https://github.com/relistan/mailtools

require 'time'

class Mbox < Array
	def initialize filename
		@filename = File.expand_path(filename)
		if !File.exist? @filename
			raise IOError, "Can't find #{@filename}"
		end
	end

	def parse 
		blank = 0
		mail = Email.new
		i = 0
		File.open(@filename, "r").each_line do |line|
			if blank && line =~ /\AFrom .*\d{4}/
				self << mail if mail.size > 0
				mail = Email.new line
				mail.index = i
				blank = 0
			else
				blank = (line =~ /\A\Z/o ? 1  : 0)
				mail << line unless (blank && i == 0)
			end
			i += 1
		end

		self << mail if mail.size > 0

		return self
	end

	def index
		parse if self.size == 0
		self.each_with_index do |message, i|
			message.parse
			puts "#{sprintf("%04d", i)}: #{sprintf("%-50s", message.Subject)} | #{message.Date}"
		end

	end
end

class Email < Array
	attr_accessor :header, :body, :index

	def initialize *args
		if !args.nil?
			self.concat args
		end
		@header = {}
		@body = []
	end
	
	def parse
		return if (@body.size > 0) || (@header.keys.size > 0) # Don't keep re-parsing

		state = :header
		self.each do |line| 
			state = :body if line =~ /\A\Z/ 

			if state == :header
				if line =~ /^([^ ]+?):(.+)$/
					key = ($1.nil? ? '' : $1)
					value = ($2.nil? ? '' : $2)
					@header[key.strip.capitalize] = value.strip
				end
			elsif state == :body
				@body << line
			end
		end

		@header['Date'] ||= Time.now.gmtime.strftime('%d-%b-%Y %H:%M:%S +0000')
		@header['Date'] = Time.parse(@header['Date']).gmtime.strftime('%d-%b-%Y %H:%M:%S +0000')

		return self
	end

	def method_missing method
		return @header[method.to_s] if @header[method.to_s]
		return @header[method.to_s.gsub(/_/, '-')]

		raise NoMethodError
	end
end

if $0 == __FILE__
	if ARGV.size > 1
		mbox = Mbox.new ARGV[0]
		mbox.parse
		mail = mbox[ARGV[1].to_i].parse
		puts
		puts "From:	#{mail.From}"
		puts "To:	#{mail.To}"
		puts "Date:	#{mail.Date}"
		puts "Subject: #{mail.Subject}"
		puts
		puts mail.body
	elsif ARGV.size == 1
		mbox = Mbox.new ARGV[0]
		mbox.index
		puts "TOTAL: #{mbox.size}"
	else
		puts "Usage: mbox.rb mboxfilename [msg_index]"
	end
end
