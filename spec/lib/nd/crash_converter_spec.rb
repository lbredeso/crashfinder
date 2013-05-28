require 'spec_helper'
require 'nd/crash_converter'

describe ND::CrashConverter do
  it "should convert a line into a hash" do
    crash_converter = ND::CrashConverter.new
    File.open("#{Rails.root}/spec/lib/nd/crash.txt").each_line.with_index do |line, index|
      crash = crash_converter.convert line
      case index
        when 0
          # Skip first line, which has column names
          crash.should == {}
        when 1
          crash[:_id].should == "ND-97915"
          crash[:_type].should == "ND::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2005"
          crash[:hour].should == "15"
          crash[:lat].should == 48.84911
          crash[:lng].should == -100.03663
        when 2
          crash[:_id].should == "ND-100623"
          crash[:_type].should == "ND::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2005"
          crash[:hour].should == "11"
          crash[:lat].should == 47.88955455
          crash[:lng].should == -97.1082863
        when 3
          crash[:_id].should == "ND-99218"
          crash[:_type].should == "ND::Crash"
          crash[:month].should == "01"
          crash[:day].should == "01"
          crash[:weekday].should == "Saturday"
          crash[:year].should == "2005"
          crash[:hour].should == "02"
          crash[:lat].should == 0
          crash[:lng].should == 0
      end
    end
  end
end
