MboxSource = 'http://bogomips.org/usp.ruby/archives/2011.mbox.gz'
MboxPath = 'src/usp.ruby.mbox.gz'

task :default => :build

desc "Build the book from start to finish"
task :build => [:fetch_sources, :generate_chapters, :convert_formats] 

directory 'src'
file MboxPath => 'src' do
  sh "curl #{MboxSource} > #{MboxPath}"
end

desc "Fetch the source mbox from bogomips.org"
task :fetch_sources => MboxPath

desc "Parse the source and generate the chapter files"
task :generate_chapters do
  puts 'Generating chapters...'

  require 'redcarpet'
  require 'unix_utils'
  require_relative 'lib/mboxparser'

  mailbox = Mbox.new UnixUtils.gunzip(MboxPath)
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

  FileUtils.mkdir_p 'src/chapters'

  articles.each do |article|
    # TODO: Pull in the replies and render those too
    date = Date.parse(article.header['Date']).to_s
    File.open("src/chapters/#{date}.html", 'w') do |fh|
      # Title
      fh.puts "<h1>#{article.header['Subject']}</h1>\n"

      # TODO: Try rendering it in a <pre> tag
      # Body
      fh.puts Redcarpet.new(article.body.join).to_html
    end
  end
end

desc "Package up the chapter files into e-reader formats"
task :convert_formats do
end

