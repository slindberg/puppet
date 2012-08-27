require 'net/http'

module Puppet::Network::HTTP

  # This class is a proxy for Net::HTTPResponse objects that provides
  # access to aspects of the request/response normally hidden. In general
  # the response objects are pretty light-weight, and nothing real fancy is
  # done with them, so the standard method_missing trick should do fine.
  class Response
    instance_methods.each { |name| undef_method name unless name.to_s.start_with? '__' or name == :object_id }

    attr_reader :session, :peer_cert, :ca_cert

    def initialize(response, session, certificates)
      @response = response
      @session = session
      @peer_cert = certificates[:peer_cert]
      @ca_cert = certificates[:ca_cert]
    end

    # proxy all methods to the response
    def method_missing(name, *args, &block)
      @response.__send__(name, *args, &block)
    end
  end
end
