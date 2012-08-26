require 'puppet/ssl/certificate_authority'
require 'puppet/ssl/host'

# Place for any authentication related bits
module Puppet::Network::Authentication
  # This doesn't actually check client authentication in the sense that it can fail; the
  # SSL handshake at the web server level takes care of that. This method only serves to
  # check the expiration of all involved certificates.
  def check_authentication(*certs)
    # Check CA cert if we're functioning as a CA
    certs << Puppet::SSL::CertificateAuthority.instance.host.certificate if Puppet::SSL::CertificateAuthority.ca?

    # Always check the host cert, this will be the agent or master cert depending on the run mode
    # NOTE: If this is called during the certificate creation process, it can result in an endless
    # network loop, due to ca file indirection having no cache yet. Unfortunately there's no real
    # good way to tell if our cert is signed without using the localhost singleton...
    certs << Puppet::SSL::Host.localhost.certificate

    # Check all certificates for upcoming expiration dates, including any that were passed
    # along since they were involved in the request
    certs.compact.each { |cert| cert.check_expiration }
  end
end
