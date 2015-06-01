class AptPkg_VersionCompare
  attr_reader :epoch, :upstream, :revision, :ver_string

  def initialize(ver_string)

    ver_string = ver_string.partition(':') # is there an epoch?
    unless ver_string[2].empty?
      @epoch = ver_string[0]
      @has_epoch = true
    else
      @epoch = '0'
      @has_epoch = false
    end

    if @has_epoch # has an epoch
      ver_string = ver_string[2].rpartition('-')
    else
      ver_string = ver_string[0].rpartition('-')
    end

    # if first part is not empty, then there is a revision
    unless ver_string[0].empty?
      @upstream = ver_string[0]
      @revision = ver_string[2] # last part
      @has_revision = true
    else # otherwise, if empty
      @upstream = ver_string[2]
      @revision = '0'
      @has_revision = false
    end


    # construct full version string
    @ver_string = "#{@epoch.to_s}:#{@upstream.to_s}"
    unless @revision == '0'
      @ver_string += "-#{@revision.to_s}"
    end

    # Check for version string validity
    unless is_valid_version?
      raise InvalidAptVersion.new('Invalid apt version string')
    end

  end

  def to_s
    @ver_string
  end
  
  private
  def is_valid_version?

    # ([0-9]+:)? parts matches the epochs. which can be only digits if presents
    # ([0-9]+[a-zA-Z0-9~.+]*) matches upstream version part.
    # it can be only alphanumeric characters, ~,. ,+ and '-' if there is a revision
    # (-[0-9]+[a-zA-Z0-9~.+]*)? matches revision part, if present.
    # can contain characters like upstream

    # return true if matched with the most general rule
    return true if valid_epoch? && valid_upstream? && valid_revision?

    false # otherwise return false
  end

  def valid_epoch?

    return true if @has_epoch && @epoch.match(/\A[0-9]+\Z/)
    return true if !@has_epoch && @epoch == '0'
    false  # otherwise return false
  end

  def valid_upstream?

    if @has_epoch && @has_revision
      valid_regex = /\A[0-9]+[a-zA-Z0-9~.+-:]*\Z/

    elsif @has_epoch && !@has_revision
      valid_regex = /\A[0-9]+[a-zA-Z0-9~.+:]*\Z/

    elsif !@has_epoch && @has_revision
      valid_regex = /\A[0-9]+[a-zA-Z0-9~.+-]*\Z/

    else
      valid_regex = /\A[0-9]+[a-zA-Z0-9~.+]*\Z/
    end

    return true if @upstream.match(valid_regex)

    false # otherwise return false

  end

  def valid_revision?

    return true if @has_revision && @revision.match(/\A[0-9]+[a-zA-Z0-9~.+]*\Z/)
    return true if !@has_revision && @revision == '0'

    false # otherwise return false
  end

end

class InvalidAptVersion < ArgumentError
  def initialize(error_msg)
    super error_msg
  end
end
