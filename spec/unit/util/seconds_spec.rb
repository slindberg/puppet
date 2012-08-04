#!/usr/bin/env ruby
require 'spec_helper'

describe Puppet::Util::Seconds do
  include Puppet::Util::Seconds

  describe ".to_seconds" do
    it { should respond_to :to_seconds }

    it "should return the same value if given an integer" do
      to_seconds(5).should == 5
    end

    it "should return an integer if given a decimal string" do
      to_seconds("12").should == 12
    end

    it "should return nil if given anything but a string or integer" do
      to_seconds("").should be_nil
      to_seconds(true).should be_nil
      to_seconds(Time.now).should be_nil
      to_seconds(8.3).should be_nil
      to_seconds([ ]).should be_nil
    end

    it "should parse strings with units of 'y', 'd', 'h', 's'" do
      # Note: this value won't jive with most methods of calculating
      # year due to the Julian calandar having 365.25 days in a year
      to_seconds("3y").should == 94608000
      to_seconds("3d").should == 259200
      to_seconds("3h").should == 10800
      to_seconds("3s").should == 3
    end

    it "should return nil if a string is poorly formatted" do
      to_seconds('foo').should be_nil
      to_seconds('2 d').should be_nil
      to_seconds('2d ').should be_nil
    end

    it "should raise an error if an error string is supplied" do
      expect { to_seconds("", "error") }.to raise_error(ArgumentError, 'error')
    end
  end
end
