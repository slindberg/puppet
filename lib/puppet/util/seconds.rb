# A small helper for manipulation of time in integer number of seconds
module Puppet::Util::Seconds
  module_function

  # How we convert from various units to seconds.
  UNITMAP = {
    # Technically the number of seconds in a year is higher due to the 1/4
    # extra day, but this is sufficient for most purposes
    "y" => 365 * 24 * 60 * 60,
    "d" => 24 * 60 * 60,
    "h" => 60 * 60,
    "s" => 1
  }

  # Convert a value to seconds (an integer), parse a numeric string with
  # units if necessary. This method is probably not worth a monkeypatch.
  def to_seconds(value, err = nil)
    case
    when value.is_a?(Integer)
      value
    when (value.is_a?(String) and value =~ /^(\d+)(y|d|h|s)?$/)
      $1.to_i * UNITMAP[$2 || 's']
    when err
      # If the value is some other type (e.g. Time), it could have a to_i
      # method that doesn't make sense, so we can't just return it.
      raise ArgumentError, err
    else
      # If an error string was not supplied, just return a falsy value.
      nil
    end
  end
end
