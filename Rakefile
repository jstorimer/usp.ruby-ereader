require 'rake/clean'
CLEAN.include FileList['src']

MboxSource = 'http://bogomips.org/usp.ruby/archives/2011.mbox.gz'
MboxPath = 'src/usp.ruby.mbox.gz'

task :default => :build

desc "Build the book from start to finish"
task :build => [:clean, :fetch_sources, :generate_chapters, :convert_formats] 

desc "Fetch the source mbox from bogomips.org"
task :fetch_sources  do
  FileUtils.mkdir_p 'src'
  sh "curl #{MboxSource} > #{MboxPath}.gz"
  sh "gunzip #{MboxPath}.gz"
end

desc "Parse the source and generate the chapter files"
task :generate_chapters do
  puts 'Generating chapters...'
  require_relative 'lib/mboxparser'

  mailbox = Mbox.new MboxPath
  mailbox.parse
  mailbox.map(&:parse)

  # Select the articles authored by Eric
  erics = mailbox.select { |mail|
    mail.header['From'].include?('Eric Wong')
  }

  # Reject replies
  articles = erics.reject { |mail|
    mail.header['Subject'].match /^Re:/
  }

  FileUtils.mkdir_p 'chapters'
  articles.each do |article|
    # TODO: Pull in the replies and render those too
    date = Date.parse(article.header['Date']).to_s
    File.open("chapters/#{date}", 'w') do |fh|
      # Title
      fh.write article.header['Subject']

      # TODO: Try rendering it in a <pre> tag
      # Body
      fh.write article.body.join
    end
  end
end

desc "Package up the chapter files into e-reader formats"
task :convert_formats do
end

