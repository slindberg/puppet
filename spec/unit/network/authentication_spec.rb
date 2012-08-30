#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'puppet/network/authentication'

class AuthenticationTest
  include Puppet::Network::Authentication
end

describe Puppet::Network::Authentication do
  subject     { AuthenticationTest.new }
  let(:cert)  { Puppet::SSL::Certificate.new('foo') }
  let(:host)  { stub 'host', :certificate => cert }

  describe "when warning about upcoming expirations" do
    before do
      Puppet::SSL::CertificateAuthority.stubs(:ca?).returns(false)
      Puppet::SSL::Host.stubs(:localhost).returns(host)
      cert.stubs(:near_expiration?).returns(false)
    end

    it "should check the expiration of the CA certificate" do
      ca_cert = Puppet::SSL::Certificate.new('cacert')
      ca_host = stub 'cahost', :certificate => ca_cert
      ca = stub 'ca', :host => ca_host
      Puppet::SSL::CertificateAuthority.stubs(:ca?).returns(true)
      Puppet::SSL::CertificateAuthority.stubs(:instance).returns(ca)
      ca_cert.expects(:near_expiration?).returns(false)
      subject.warn_if_near_expiration
    end

    it "should check the expiration of the localhost certificate" do
      cert = Puppet::SSL::Certificate.new('localcert')
      localhost = stub 'localhost', :certificate => cert
      Puppet::SSL::Host.stubs(:localhost).returns(localhost)
      cert.expects(:near_expiration?).returns(false)
      subject.warn_if_near_expiration
    end

    it "should check the expiration of any certificates passed in as arguments" do
      cert1 = Puppet::SSL::Certificate.new('cert1')
      cert2 = Puppet::SSL::Certificate.new('cert2')
      cert1.expects(:near_expiration?).returns(false)
      cert2.expects(:near_expiration?).returns(false)
      subject.warn_if_near_expiration(cert1, cert2)
    end

    it "should accept instances of OpenSSL::X509::Certificate" do
      cert = Puppet::SSL::Certificate.new('cert3')
      raw_cert = stub 'cert'
      raw_cert.stubs(:is_a?).with(OpenSSL::X509::Certificate).returns(true)
      Puppet::SSL::Certificate.stubs(:from_instance).with(raw_cert).returns(cert)
      cert.expects(:near_expiration?).returns(false)
      subject.warn_if_near_expiration(raw_cert)
    end

    it "should log a warning if a certificate's expiration is near" do
      cert = Puppet::SSL::Certificate.new('cert4')
      cert.stubs(:unmunged_name).returns('foo')
      cert.stubs(:expiration).returns(Time.now)
      cert.stubs(:near_expiration?).returns(true)
      Puppet.expects(:warning)
      subject.warn_if_near_expiration(cert)
    end

    it "should never log a warning more than once within a `runinterval`" do
    end

    # it "should not log a warning when `ca_ttl` value is less than `certificate_expire_warning`" do
    # end

    it "should use the name from the subject of the certificate in the warning" do
    end
  end
end
