require 'puppet/util/seconds'

module Puppet::Util::ConfigTimeout
  include Puppet::Util::Seconds

  # NOTE: in the future it might be a good idea to add an explicit "integer" type to
  #  the settings types, in which case this would no longer be necessary.

  # Get the value of puppet's "configtimeout" setting, as an integer.  Raise an
  # ArgumentError if the setting does not contain a valid integer value.
  # @return Puppet config timeout setting value, as an integer
  def timeout_interval
    timeout = Puppet[:configtimeout]

    # to_seconds will raise an eror if anything other than an Integer or parsable
    # string are given (this also allows this setting to be specified using units
    # like 'd', 'h', 's', which can't hurt)
    to_seconds timeout, "Configuration timeout must be an integer, '#{timeout}' given"
  end
end
