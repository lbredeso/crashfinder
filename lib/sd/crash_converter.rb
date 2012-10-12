require 'csv'

module SD
  class CrashConverter
    def initialize year
      @year = year
    end
    
    def convert line
      crash = {}
      
      # There's some illegal quoting going on, like O"BRIEN.
      line.gsub! "\"", "'"
      
      row = CSV.parse line, { col_sep: "|" }
      unless row[0][0] == "AccidentSeqID"
        puts "Loading SD crash #{row[0][1]}"
        crash[:_id] = "SD-#{row[0][1]}"
        crash[:_type] = "SD::Crash"
        
        # Date and Time
        row[0][2] =~ /([\d]{1,2})\/([\d]{1,2})\/([\d]{4})\ ([\d]{1,2}):([\d]{2}):([\d]{2})\ ([A-Z]{2})/
        crash[:month] = $1.to_s.rjust 2, "0"
        crash[:day] = $2.to_s.rjust 2, "0"
        crash[:year] = $3
        crash[:hour] = ($4.to_i + ($7 == "PM" ? 12 : 0)).to_s.rjust(2, "0")
        crash[:minute] = $5
        
        # Location
        crash[:lat] = row[0][100].to_f
        crash[:lng] = row[0][101].to_f
      end
      crash
    end
    
    def file_name
      "crash/Accident#{@year}.txt"
    end
  end
end