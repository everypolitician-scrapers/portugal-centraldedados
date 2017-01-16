#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'pry'
require 'scraperwiki'

def json_from(url)
  JSON.parse(open(url).read, symbolize_names: true)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

added = Hash.new(0)
json = json_from('https://raw.githubusercontent.com/centraldedados/parlamento-deputados/master/data/deputados.json')
json.values.each do |v|
  mp_data = {
    id:                     v[:id],
    identifier__parlamento: v[:id],
    name:                   v[:shortname],
    full_name:              v[:name],
    birth_date:             v[:birthdate],
    image:                  v[:image_url],
    source:                 v[:url_parlamento],
  }

  v[:mandates].each do |m|
    term_data = {
      term:       m[:legislature],
      party:      m[:party],
      area:       m[:constituency],
      start_date: m[:start_date],
      end_date:   m[:end_date],
    }

    data = mp_data.merge term_data
    # puts data
    ScraperWiki.save_sqlite(%i(id term), data)
    added[term_data[:term]] += 1
  end
end
puts "  Added #{added}"
