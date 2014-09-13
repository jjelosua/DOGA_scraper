Galician Official journal (DOGA) Scraper
================================================

#### Introduction

It seems that the easiest way to access the DOGA dispositions is through the [DOGA search page][1]
filtering the desired dates.

This scraper was created and used as a socurce for the publication of this [data journalism story][2]

[1]: http://www.xunta.es/diario-oficial-galicia/buscarAnunciosPublico.do?key_confirmacion=&compMenu=10102
[2]: http://www.elmundo.es/espana/2014/09/08/53db8b6d268e3ef5488b4576.html

#### Script description

The script expects a year as an input parameter and scrapes all the available documents to the data folder (automatically created). It creates a folder with the year passed as an argument and stores the documents in two formats PDF and HTML. 

If some unexpected behaviour is found the script logs the details inside the logs folder (automatically created)

#### Script requirements

Ruby script
* require 'mechanize'
* require 'fileutils'

Rake file
* require 'pty' # To buffer out the stdout

#### Execution of the script

* To run the script

    $ rake scrape:DOGA[2014]


