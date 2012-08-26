#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'puppet/network/authentication'

class AuthenticationTest
  include Puppet::Network::Authentication
end

describe Puppet::Network::Authentication do
  before :each do
    @test = AuthenticationTest.new
  end

  describe "when checking authentication" do
    it "should check the expiration of the CA certificate" do
      cert = stub 'cert'
      host = stub 'host', :certificate => cert
      ca = stub 'ca', :host => host
      Puppet::SSL::CertificateAuthority.stubs(:ca?).returns(true)
      Puppet::SSL::CertificateAuthority.stubs(:instance).returns(ca)
      Puppet::SSL::Host.stubs(:localhost).returns(stub_everything)

      cert.expects(:check_expiration)

      @test.check_authentication
    end

    it "should check the expiration of the localhost certificate" do
      cert = stub 'cert'
      host = stub 'host', :certificate => cert
      Puppet::SSL::Host.stubs(:localhost).returns(host)
      Puppet::SSL::CertificateAuthority.stubs(:ca?).returns(false)

      cert.expects(:check_expiration)

      @test.check_authentication
    end

    it "should check the expiration of any certificates passed in as arguments" do
      cert1 = stub 'cert1'
      cert2 = stub 'cert2'
      Puppet::SSL::Host.stubs(:localhost).returns(stub_everything)
      Puppet::SSL::CertificateAuthority.stubs(:ca?).returns(false)

      cert1.expects(:check_expiration)
      cert2.expects(:check_expiration)

      @test.check_authentication cert1, cert2
    end
  end
end
