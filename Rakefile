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

require 'redcarpet'
class HTMLWithoutHr < Redcarpet::Render::HTML
  def hrule()
    ''
  end
end

desc "Parse the source and generate the chapter files"
task :generate_chapters do
  puts 'Generating chapters...'

  require 'unix_utils'
  require 'erb'
  require_relative 'lib/mboxparser'

  mailbox = Mbox.new UnixUtils.gunzip(MboxPath)
  mailbox.parse
  mailbox.map(&:parse)

  # Select the articles authored by Eric
  erics = mailbox.select { |mail|
    mail.header['From'].include?('Eric Wong')
  }

  # Reject replies and fwds
  articles = erics.reject { |mail|
    mail.header['Subject'].match /^(Re|Fwd):/
  }

  FileUtils.mkdir_p 'src/chapters'

  articles.each do |article|
    # TODO: Pull in the replies and render those too
    date = Date.parse(article.header['Date']).to_s
    File.open("src/chapters/#{date}.html", 'w') do |fh|

      title = article.header['Subject']

      # TODO: Try rendering it in a <pre> tag
      markdown = Redcarpet::Markdown.new(HTMLWithoutHr)
      content = markdown.render(article.body.join)

      template = ERB.new(File.read('lib/page_template.erb'))
      fh.write template.result(binding)
    end
  end
end

directory 'books'

desc "Package up the chapter files into e-reader formats"
task :convert_formats => ['books', :epub, :mobi]

task :epub do
  puts 'Converting to e-reader formats...'

  require 'eeepub'
  require 'nokogiri'
  require 'date'

  epub = EeePub.make do
    title      'usp.ruby Archives'
    creator    'Eric Wong'
    publisher  'Jesse Storimer'
    date       Date.today.to_s
    identifier 'http://bogomips.org/usp.ruby/README', :scheme => 'URL'
    uid        'http://bogomips.org/usp.ruby/README'

    #cover_page ''
    #toc_page   ''

    files      Dir['src/chapters/*.html']

    nav(Dir['src/chapters/*.html'].map do |chapter|
      content = File.read(chapter)
      html = Nokogiri(content)
      title = html.css('h1').first.text

      {:label => title, :content => File.basename(chapter)}
    end.to_a)
  end

  epub.save('books/usp.ruby.epub')
end

task :mobi => :epub do
  sh 'kindlegen books/usp.ruby.epub'
end

