require 'pty'

namespace 'scrape' do
  desc "Scrape Galician official journal"
  task :DOGA, :year do |t, args|
    puts "Scrape Galician official journal for year #{args.year} ..."
    begin
      PTY.spawn("#{File.dirname(__FILE__)}/scrapeDOGA.rb #{args.year}") do |stdin, stdout, pid|
        stdin.each { |line| puts line }
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end
  end
end