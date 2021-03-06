require 'spec_helper'
require 'sd/crash_converter'

describe SD::CrashConverter do
  it "should proclaim a valid file name" do
    crash_converter = SD::CrashConverter.new "2011"
    crash_converter.file_name.should == "crash/Accident2011.txt"
  end
  
  it "should convert a line into a hash" do
    crash_converter = SD::CrashConverter.new "2011"
    File.open("#{Rails.root}/spec/lib/sd/crash.txt").each_line.with_index do |line, index|
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
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2011"
          crash[:hour].should == "17"
          crash[:lat].should == 44.273045
          crash[:lng].should == -103.735260
        when 2
          crash[:_id].should == "SD-412402"
          crash[:_type].should == "SD::Crash"
          crash[:month].should == "10"
          crash[:day].should == "23"
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2004"
          crash[:hour].should == "22"
          crash[:lat].should == 42.793721
          crash[:lng].should == -96.943114
        when 3
          crash[:_id].should == "SD-1100146"
          crash[:_type].should == "SD::Crash"
          crash[:month].should == "01"
          crash[:day].should == "03"
          crash[:weekday].should == "Monday"
          crash[:year].should == "2011"
          crash[:hour].should == "08"
          crash[:lat].should == 43.608895
          crash[:lng].should == -96.939219
      end
    end
  end
end
