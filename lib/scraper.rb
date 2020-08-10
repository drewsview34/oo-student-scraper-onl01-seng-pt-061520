require 'open-uri'
require 'nokogiri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    doc = Nokogiri::HTML(open(index_url))
    students = [ ]
    
    doc.css("div.roster-cards-container").each do |card|
      card.css(".student-card a").each do |profile|
        profile_link = "#{profile.attr("href")}"
        profile_location = profile.css('.student-location').text 
        profile_name = profile.css('.student-name').text
        students << { name: profile_name, location: profile_location, profile_url: profile_link }
      end
    end
    students
  end

  def self.scrape_profile_page(profile_url)
    doc = Nokogiri::HTML(open(profile_url))
    social_links = {}
    
    links = doc.css(".social-icon-container").children.css("a").collect{ |account| account.attribute("href").value }
    links.each do |link|
      if link.include?("linkedin")
         social_links[:linkedin] = link
      elsif link.include?("github")
         social_links[:github] = link
      elsif link.include?("twitter")
         social_links[:twitter] = link
      else 
         social_links[:blog] = link
      end
    end
    social_links[:profile_quote] = doc.css(".profile-quote").text if doc.css(".profile-quote")
    
    social_links[:bio] = doc.css("div.bio-content.content-holder div.description-holder p").text if doc.css("div.bio-content.content-holder div.description-holder")
    
    social_links
  end
end