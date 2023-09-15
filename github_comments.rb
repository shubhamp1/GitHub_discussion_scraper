# github_spider.rb
require 'kimurai'
require 'uri'
require 'pry'
require 'json'
require  'net/http'
require 'csv'

class GithubSpider < Kimurai::Base
  @name = "github_spider"
  @engine = :mechanize
	puts "Please enter comment word"
  @@search_query = gets
  @start_urls = ["https://github.com/search?q=#{@@search_query}&type=discussions"]
  @@urls = []
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 4..7 }
  }

  def parse(response, url, data: {})

		# parsed_page = response.xpath("//p")&.text
		# json_data = JSON.parse(parsed_page)
		# page_count = json_data["payload"]["page_count"] + 1


		# parse_csv(page_count, url)
		end_comments
  end

  # Create a CSV 
	def parse_csv(page_count, url)

		csv_name = "sh_#{@@search_query}_#{Time.now}.csv"

		CSV.open(csv_name, 'wb') do |csv|
			csv << ['Comment']

			page_count.times do |pg|
				if pg > 0
					begin
						page = request_to :parse_page, url: "#{url[:url]}&p=#{pg}", data: { csv: csv }
					rescue Exception => e
						puts e.message
					end
				end
			end
		end
	end

	# Parse the all page of github comments
  def parse_page(response, url, data: {})

		csv = url[:data][:csv]
		parsed_page = response.xpath("//p")&.text
		json_data = JSON.parse(parsed_page)
		json_data["payload"]["results"].each do |data|
			number = data['number']
			body = data["body"]

			if  data['num_comments'] > 0
				parse_comments(csv, data['url']) 
			else
				csv << [body&.squish]
			end
		end
		
  end

	# Parse the comments of github page
	def parse_comments(csv, url, data: {})
		@base_uri = 'https://github.com/'
		browser.visit(@base_uri + url)
		page_response = browser.current_response
		parse_comments =  page_response.css("tr td")
		parse_comments.each do |comment|
			csv << [comment&.text&.squish]
		end
  end

	def end_comments
		puts "\n\n"
		puts "#########################################################################"
		puts "#########################################################################"
		puts "Comment word is #{@@search_query}"
		puts "Successfully data stored in CSV. "
		puts "This script was developed by Shubham. For inquiries, please contact:"
		puts "- Email: shubhamchandroliya2014@gmail.com"
		puts "#########################################################################"
		puts "#########################################################################"
	end
end

GithubSpider.crawl!