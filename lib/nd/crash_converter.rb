require 'csv'
require 'pp'

module ND
  class CrashConverter
    def convert line
      crash = {}
      row = CSV.parse line
      unless row[0][0] == "CRASH_NO"
        puts "Loading ND crash #{row[0][0]}"
        crash[:_id] = "ND-#{row[0][0]}"
        crash[:_type] = "ND::Crash"
        
        # Date
        row[0][5] =~ /([\d]{4})\-([\d]{2})\-([\d]{2})\ 00:00:00/
        crash[:year] = $1
        crash[:month] = $2
        crash[:day] = $3
        
        # Time
        row[0][6] =~ /[\d]{4}\-[\d]{2}\-[\d]{2}\ ([\d]{2}):([\d]{2}):00/
        crash[:hour] = $1
        crash[:minute] = $2
        
        # Location
        crash[:lat] = row[0][7].to_f
        crash[:lng] = row[0][8].to_f
      end
      crash
    end
  end
end