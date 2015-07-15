require 'json'
require 'open-uri'
require 'nokogiri'
require 'google-search'
#require 'slack-notifier'
class MainController < ApplicationController
def google_info
  google_links = []
  count = 0
  begin
    Google::Search::Web.new(:query => ("980 site:microcenter.com")).each do |web|
        if count<25
          google_links << web.uri
          count+=1
        else
          break
        end
      end
  rescue
  end
  return google_links
end

def google_info1
  google_links = []
  count = 0
  begin
    Google::Search::Web.new(:query => ("970 site:microcenter.com")).each do |web|
        if count<25
          google_links << web.uri
          count+=1
        else
          break
        end
      end
  rescue
  end
  return google_links
end

def send_to_slack(price,link)
  notifier = Slack::Notifier.new ENV["WEBHOOK"]
  notifier.ping link +  "\n" + price
end

def output_to_text_file(price,link)
  exists = false
  File.open("micro_deals.txt",'r') do |f|
    f.each_line do |line|
      if line.strip.eql?(link.strip + price.strip)
        exists = true
      end
    end
  end
  File.open('micro_deals.txt', 'a') do |f|
    if !exists && price.gsub("$","").to_i<35000 && 
      price.gsub("$","").to_i != 0
      f.puts (link + price)
      send_to_slack(price,link)
    end
  end
end

def process_link(link)
  if link.downcase.include?("gtx") && link.downcase.include?("product")
    page = Nokogiri::HTML.parse(open(link))
    if page.css("#options")
      options_css = page.css("#options")
      if options_css.css("#pricing")
        price_of_item = options_css.css("#pricing").text
        @solution<<link
        @solution_price<<price_of_item.gsub("$","")
        #output_to_text_file(price_of_item,link)
      end
    end
  end
end

def process_link1(link)
  if link.downcase.include?("gtx") && link.downcase.include?("product")
    page = Nokogiri::HTML.parse(open(link))
    if page.css("#options")
      options_css = page.css("#options")
      if options_css.css("#pricing")
        price_of_item = options_css.css("#pricing").text
        @solution970<<link
        @solution_price970<<price_of_item.gsub("$","")
        #output_to_text_file(price_of_item,link)
      end
    end
  end
end

def start_method()
  @solution = []
  @solution_price = []
  google_links = google_info
  google_links.each do |link|
    process_link(link)
  end
  @solution_price,@solution = @solution_price.zip(@solution).sort.transpose

  @solution970 = []
  @solution_price970 = []
  google_links = google_info1
  google_links.each do |link|
    process_link1(link)
  end
  @solution_price970,@solution970 = @solution_price970.zip(@solution970).sort.transpose
end


  def index
    start_method
  end
end
