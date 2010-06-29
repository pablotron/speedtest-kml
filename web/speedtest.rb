#!/usr/bin/env ruby

require 'pp'
require 'csv'

module SpeedTest
  VERSION = '0.1.0'


  USAGE = <<-END_USAGE
#$0 - convert SpeedTest CSV files to KML.

Examples:

  # convert an input csv file named "in.csv" to "out.kml"
  #$0 in.csv > out.kml

  # merge two speedtest csv files and export a KML file named "data.kml"
  #$0 data-1.csv data-2.csv > all.kml
END_USAGE

  module Util
    def self.template(str, args = nil) 
      str.gsub(/\{(\w+)\}/mx) { args[$1] || '' }
    end

    def self.h(s)
      s.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;').gsub(/"/, '&quot;')
    end

    def self.hh(h)
      h.inject({}) { |r, a| r[a[0]] = h(a[1]); r }
    end
  end

  class CSVReader
    TEMPLATES = {
      'name' => '{download} ({conntype}, {date})',

      'description' => %(
        date = {date}, server = {servername},
        download = {download}, upload = {upload}, latency = {latency}
      ),
    }

    def run(data, &block)
      header = true

      CSV.parse(data) do |row|
        if header
          @cols = row.map { |v| v.downcase }
          header = false
        else
          block.call(convert_row(row))
        end
      end
    end

    private 

    def convert_row(row)
      to_loc(to_hash(row))
    end

    #
    # convert input row to hash
    #
    def to_hash(row)
      r = {}
      row.each_with_index { |v, i| r[@cols[i]] = v }
      r
    end

    #
    # convert source hash from input csv to location hash
    #
    def to_loc(src)
      src = Util.hh(src)

      src.merge(TEMPLATES.inject({}) do |r, a| 
        r[a[0]] = Util.template(a[1], src); r
      end)
    end

  end

  #
  # Minimal KML generator.
  #
  class KML
    TEMPLATES = {
      'loc' => %(
        <Placemark>
          <name>{name}</name>
          <description>{description}</description>
          <Point>
            <coordinates>{lon},{lat}</coordinates>
          </Point>
        </Placemark>
      ).strip,

      'kml' => %(
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          {body}
        </kml>
      ).strip,
    }

    def initialize
      @locs = []
    end

    def add_location(loc)
      @locs << loc
      loc
    end

    alias :<< :add_location

    def to_s
      template('kml', {
        'body' => @locs.map { |loc| template('loc', loc) }.join
      })
    end

    private

    def template(key, args = nil) 
      Util.template(TEMPLATES[key], args)
    end
  end

  #
  # SpeedTest CSV to KML converter.
  #
  class Converter
    def self.run(data)
      new.run(data)
    end

    def run(data)
      @csv ||= CSVReader.new
      kml = KML.new

      # read/convert input file
      @csv.run(data) { |loc| kml << loc }

      # return result
      kml.to_s
    end
  end
end
