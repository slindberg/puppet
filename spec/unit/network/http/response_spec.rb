#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'net/http'
require 'puppet/network/http/response'

describe Puppet::Network::HTTP::Response do
  let(:net_response) { Net::HTTPOK.new('1.1', 200, '') }
  let(:session) { stub 'session' }
  let(:certs) { { :ca_cert => stub('cacert'), :peer_cert => stub('peercert') } }
  subject { Puppet::Network::HTTP::Response.new(net_response, session, certs) }

  it "should behave like a Net::HTTPResponse object" do
    subject.is_a?(Net::HTTPOK).should be_true
    subject.kind_of?(Net::HTTPSuccess).should be_true
    subject.code.should == 200
  end

  it "should expose request session and certificates" do
    subject.session.should == session
    subject.ca_cert.should == certs[:ca_cert]
    subject.peer_cert.should == certs[:peer_cert]
  end
end
