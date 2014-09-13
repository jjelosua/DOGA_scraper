#!/usr/bin/env ruby
# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'mechanize'

def getQuery(year) 
  get_params = "&anuncioSearchFiltro.fechaDesde=01/01/#{year}"
  get_params << "&anuncioSearchFiltro.fechaHasta=31/12/#{year}"
  get_params << "&validationForward=formBuscarAnuncio"
  get_params << "&valida=true"
end

#Create the folders where the data and logs will be stored
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)

#To complete relative paths
HOME_URL = 'http://www.xunta.es/diario-oficial-galicia/buscarAnunciosPublico.do?key_confirmacion=&compMenu=10102'
SEARCH_URL = 'http://www.xunta.es/diario-oficial-galicia/buscarAnunciosPublico.do?method=listado'
#Get the desired scrape year from arguments
YEAR = ARGV[0]

#Extract script name
$0 =~ /^.*\/(.*)\.rb/
if $1.nil?
  script_name = $0.gsub(/\.rb/,"")
else
  script_name = $1
end

#Create the log file
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')

#Instantiate the mechanize object
agent = Mechanize.new

#Get the cookie from the main page
begin
  page = agent.get(HOME_URL)
rescue Mechanize::ResponseCodeError => the_error
  log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
  return
end

for year in YEAR..YEAR
  output_html = "data/#{year}/html"
  output_pdf = "data/#{year}/pdf"
  FileUtils.makedirs(output_html)
  FileUtils.makedirs(output_pdf)
  
  #Issue a post to obtain the number of pages of results
  begin
    params = {
      "anuncioSearchFiltro.fechaDesde"=> "01/01/#{year}",
      "anuncioSearchFiltro.fechaHasta"=> "31/12/#{year}",
      "validationForward"=> "formBuscarAnuncio",
      "primeraConsulta"=>"false",
      "valida"=>"true"  
    }
    page = agent.post(SEARCH_URL, params)
  rescue Mechanize::ResponseCodeError => the_error
    log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
  end

  #Get the nokogiri parsed document
  doc = page.parser

  last_href = doc.css("span.pagelinks a").last["href"]
  last_href =~ /d-16396-p=(\d+)/
  last_page = $1.to_i
  
  #Scrape each page and extract the html and pdf files
  get_params = getQuery(year)
  for i in 1..last_page
    puts "Processing page #{i}"
    params = get_params + "&d-16396-p=#{i}"
    url = "#{SEARCH_URL}#{params}"
    begin
      page = agent.get(url)
    rescue Mechanize::ResponseCodeError => the_error
      log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
      return
    end
  
    #Get the nokogiri parsed document
    doc = page.parser
    links = doc.css("table.tabla td.itemResultado a")
    links.each do |link|
      href = link["href"]
      href =~ /\.(html|pdf)$/
      if !$1.nil?
        filetype = $1 
        href =~ /.*\/(.*)$/
        filename = $1
        url = "http://www.xunta.es" + href
        output_subdir = (filetype.eql? "html") ? output_html : output_pdf
        unless File.exists?("#{output_subdir}/#{filename}")
          begin
            agent.get(url).save!("#{output_subdir}/#{filename}")
          rescue
            log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
          end
        end # File already exists
      end #end if file_type 
    end #end loop links
    # Give the remote site a break
    sleep(1)
  end #end loop pages
end
log_file.close
