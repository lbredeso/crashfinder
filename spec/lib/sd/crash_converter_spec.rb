require 'spec_helper'
require 'sd/crash_converter'

describe SD::CrashConverter do
  it "should proclaim a valid file name" do
    crash_converter = SD::CrashConverter.new "2011"
    crash_converter.file_name.should == "crash/Accident2011.txt"
  end
  
  it "should convert a line into a hash" do
    crash_converter = SD::CrashConverter.new "2011"
    File.open("spec/lib/sd/crash.csv").each_line.with_index do |line, index|
      crash = crash_converter.convert line
      case index
        when 0
          # Skip first line, which has column names
          crash.should == {}
        when 1
          crash[:_id].should == "SD-1100001"
          crash[:_type].should == "SD::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:year].should == "2011"
          crash[:hour].should == "17"
          crash[:minute].should == "00"
          crash[:lat].should == 44.273045
          crash[:lng].should == -103.735260
        when 2
          crash[:_id].should == "SD-1100002"
          crash[:_type].should == "SD::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:year].should == "2011"
          crash[:hour].should == "23"
          crash[:minute].should == "40"
          crash[:lat].should == 44.703862
          crash[:lng].should == -100.066176
        when 3
          crash[:_id].should == "SD-1100146"
          crash[:_type].should == "SD::Crash"
          crash[:month].should == "01"
          crash[:day].should == "03"
          crash[:year].should == "2011"
          crash[:hour].should == "08"
          crash[:minute].should == "55"
          crash[:lat].should == 43.608895
          crash[:lng].should == -96.939219
      end
    end
  end
end