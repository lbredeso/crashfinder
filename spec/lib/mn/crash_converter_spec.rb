require 'spec_helper'
require 'mn/crash_converter'

describe MN::CrashConverter do
  it "should proclaim a valid file name" do
    crash_converter = MN::CrashConverter.new "2011"
    crash_converter.file_name.should == "crash/mn-2011-acc.txt"
  end
  
  it "should convert a line into a hash" do
    File.open("#{Rails.root}/spec/lib/mn/crash.txt").each_line.with_index do |line, index|
      crash = {}
      case index
        when 0
          crash_converter = MN::CrashConverter.new "1997"
          crash = crash_converter.convert line
          crash[:_id].should == "MN-0700100021997"
          crash[:_type].should == "MN::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Wednesday"
          crash[:year].should == "1997"
          crash[:hour].should == "03"
          crash[:route_id].should == "04000044"
          crash[:mile_point].should == 1.984
        when 1
          crash_converter = MN::CrashConverter.new "2004"
          crash = crash_converter.convert line
          crash[:_id].should == "MN-0400100272004"
          crash[:_type].should == "MN::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Thursday"
          crash[:year].should == "2004"
          crash[:hour].should == "15"
          crash[:route_id].should == "0510400126"
          crash[:mile_point].should == 1.159
        when 2
          crash_converter = MN::CrashConverter.new "2011"
          crash = crash_converter.convert line
          crash[:_id].should == "MN-1100100252011"
          crash[:_type].should == "MN::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2011"
          crash[:hour].should == "04"
          crash[:route_id].should == "0533800160"
          crash[:mile_point].should == 0.056
      end
      crash[:acctim2].should be_nil
      crash[:acchour].should be_nil
    end
  end
end
