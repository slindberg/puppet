require 'puppet/ssl/base'
require 'puppet/ssl/certificate_factory'

# Manage certificates themselves.  This class has no
# 'generate' method because the CA is responsible
# for turning CSRs into certificates; we can only
# retrieve them from the CA (or not, as is often
# the case).
class Puppet::SSL::Certificate < Puppet::SSL::Base
  # This is defined from the base class
  wraps OpenSSL::X509::Certificate

  extend Puppet::Indirector
  indirects :certificate, :terminus_class => :file

  # Because of how the format handler class is included, this
  # can't be in the base class.
  def self.supported_formats
    [:s]
  end

  def subject_alt_names
    alts = content.extensions.find{|ext| ext.oid == "subjectAltName"}
    return [] unless alts
    alts.value.split(/\s*,\s*/)
  end

  def expiration
    return nil unless content
    content.not_after
  end

  # Log a warning if the cert is close to expiring
  def check_expiration
    lead_time = Puppet[:certificate_expire_warning]
    identifier = self.class.name_from_subject(content.subject)

    # Don't bother with a warning if the ca_ttl setting is shorter than the expire warning setting,
    # it probably means there's some testing going on
    if lead_time < Puppet.settings[:ca_ttl] and expiration < Time.now.utc + lead_time
      Puppet.warning "Certificate '#{identifier}' will expire on #{expiration.strftime('%Y-%m-%dT%H:%M:%S%Z')}"
    end
  end
end
