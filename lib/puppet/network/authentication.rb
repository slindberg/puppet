require 'puppet/ssl/certificate_authority'
require 'puppet/ssl/configuration'

# Place for any authentication related bits
module Puppet::Network::Authentication
  # Class variable used to throttle cert warnings and avoid spamming the logs
  @@last_warn = {}

  # Use the global localhost instance.
  def ssl_host
    Puppet::SSL::Host.localhost
  end

  def ssl_configuration
    @ssl_configuration ||= Puppet::SSL::Configuration.new(
      Puppet[:localcacert],
      :ca_chain_file => Puppet[:ssl_client_ca_chain],
      :ca_auth_file  => Puppet[:ssl_client_ca_auth]
    )
  end

  def host_cert_exists?
    FileTest.exist?(Puppet[:hostcert])
  end

  def ca_cert_exists?
    FileTest.exist?(ssl_configuration.ca_auth_file)
  end

  # Check the expiration of known certificates and optionally any that are specified as part of a request
  def warn_if_near_expiration(*certs)
    # Check CA cert if we're functioning as a CA
    certs << Puppet::SSL::CertificateAuthority.instance.host.certificate if Puppet::SSL::CertificateAuthority.ca?

    # Always check the host cert if we have one, this will be the agent or master cert depending on the run mode
    certs << Puppet::SSL::Host.localhost.certificate if host_cert_exists?

    # Remove nil values for caller convenience
    certs.compact.each do |cert|
      # Allow raw OpenSSL certificate instances or Puppet certificate wrappers to be specified
      cert = Puppet::SSL::Certificate.from_instance(cert) if cert.is_a?(OpenSSL::X509::Certificate)
      raise ArgumentError, "Invalid certificate '#{cert.inspect}'" unless cert.is_a?(Puppet::SSL::Certificate)

      if cert.near_expiration? and can_warn?(cert)
        Puppet.warning "Certificate '#{cert.unmunged_name}' will expire on #{cert.expiration.strftime('%Y-%m-%dT%H:%M:%S%Z')}"
      end
    end
  end

  private

  # Never warn more than once per agent run interval, per cert
  def can_warn?(cert)
    return false unless !@@last_warn.include?(cert.name) or @@last_warn[cert.name] + Puppet[:runinterval] < Time.now
    @@last_warn[cert.name] = Time.now
    true
  end
end
