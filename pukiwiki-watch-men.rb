# -*- coding: utf-8 -*-
#!/usr/bin/ruby

require 'rubygems'
require 'uri'
require 'rss'
require 'redis'
require 'json'
require 'idobata'

class PukiWikiRssReader
  def initialize (rss_url)
    charset = nil
    rss_source = open(rss_url) do |f|
      charset = f.charset
      f.read
    end

    uri = URI.parse( ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

    @rss = nil
    begin
      @rss = RSS::Parser.parse(rss_source)
    rescue RSS::InvalidRSSError
      @rss = RSS::Parser.parse(rss_source, false)
    end
  end

  def get_new_items
    new_items = []
    @rss.items.each do |item|
      if update?(item)
        item_info = {
          'title' => item.title,
          'date' => item.pubDate,
          'link' => item.link
        }
        new_items << item_info
      end
    end
    self.update_redis

    return new_items
  end

  def update_redis
    items_json = self.to_json
    @redis.set('previous', items_json)
  end

  def get_redis
    previous_items = @redis.get('previous')
    return false unless previous_items

    previous_items_json = JSON.load(previous_items)
    return previous_items_json
  end

  def update?(item)
    previous_items = self.get_redis
    return false unless previous_items

    previous_items.each do |previous_item|
      date = previous_item['date']
      title = previous_item['title']
      return true if (date == item.pubDate.to_s && title == item.title)
    end

    return true
  end

  def to_json
    items_info = []
    @rss.items.each do |item|
      item_info = {
        'title' => item.title,
        'date' => item.pubDate
      }
      items_info << item_info
    end

    json = JSON.generate(items_info)
    return json
  end
end

rss_url = ENV["PUKIWIKI_RSS_URL"]
hook_url = ENV["IDOBATA_HOOK_URL"]

unless rss_url || hook_url
  puts 'Prease set ENV["PUKIWIKI_RSS_URL"] and ENV["IDOBATA_HOOK_URL"]'
  exit
end

pukiWikiRssReader = PukiWikiRssReader.new(rss_url)
new_items = pukiWikiRssReader.get_new_items

Idobata.hook_url = hook_url

new_items.each do |item|
  source = "『#{item['title']}』が更新されました。 - #{item['link']}"
  Idobata::Message.create(source: source, label: { type: :warning, text: "HIT Wiki" })
  puts "SEND: #{source}"
end
