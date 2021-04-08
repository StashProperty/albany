require 'scraperwiki'
require 'mechanize'
require 'date'

date_scraped = Date.today.to_s


url = 'https://www.wtc.tas.gov.au/Your-Property/Planning/Currently-Advertised-Planning-Applications'
info_url = 'https://www.wtc.tas.gov.au/Your-Property/Planning/Currently-Advertised-Planning-Applications/pa-no'
agent = Mechanize.new
page = agent.get(url)

applicationSet = page.search('article')[1..-1]


applicationSet.each do |row|
	record = {}
	record['date_received'] = row.at("time").text.strip()
	record['date_scraped'] = date_scraped
	row.search("strong").each do |subrow|
		subrow.text.split("\n").each do |line|
			name = line.strip().split(": ")
			case name[0]
				when 'PA NO'
					record['council_reference'] = name[1]
				when 'PROPOSAL'
					record['description'] = name[1]
				when 'LOCATION'
					record['address'] = name[1]
			end
		end
	end
	puts "Saving #{record['council_reference']}, #{record['address']}"
	ScraperWiki.save_sqlite(['council_reference'], record)
end
