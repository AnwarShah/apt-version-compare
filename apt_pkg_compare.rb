class AptPkg_VersionCompare
  attr_reader :epoch, :upstream, :revision, :ver_string

  def initialize(ver_string)
    ver_string = ver_string.split(':') # is there an epoch?
    @epoch = ver_string.length == 2 ? ver_string[0] : '0'

    unless @epoch == '0' # has an epoch
      ver_string = ver_string[1].split('-')
    else
      ver_string = ver_string[0].split('-')
    end

    @upstream = ver_string[0]
    if ver_string.length == 2 # there is a revision
      @revision = ver_string[1]
    else
      raise InvalidAptVersion.new('Invalid version string')
    end

    # construct full version string
    @ver_string = "#{@epoch.to_s}:#{@upstream.to_s}"
    unless @revision == '0'
      @ver_string += "-#{@revision.to_s}"
    end

    # Check for version string validity
    is_valid_version?(@ver_string)

  end

  def to_s
    @ver_string
  end
  
  private
  def is_valid_version?(ver_string)

    valid_version_regex = /^([0-9]+:)?([0-9]+[a-zA-Z0-9~.+]*)(-[0-9]+[a-zA-Z0-9~.+]*)?$/
    #Explanation of the regex
    # ([0-9]+:)? parts matches the epochs. which can be only digits if presents
    # ([0-9]+[a-zA-Z0-9~.+]*) matches upstream version part.
    # it can be only alphanumeric characters, ~,. ,+ it must be present
    # (-[0-9]+[a-zA-Z0-9~.+]*)? matches revision part, if present.
    # can contain characters like upstream

    unless ver_string.match( valid_version_regex )
      raise InvalidAptVersion.new('Invalid version string')
    end

  end

end

class InvalidAptVersion < ArgumentError
  def initialize(error_msg)
    super error_msg
  end
end

# cmp1 = AptPkg_VersionCompare.new('1.0+32-1beta1~svn1245')
cmp1 = AptPkg_VersionCompare.new('29:0.29-3')
puts 'epoch: ' + cmp1.epoch if cmp1.epoch
puts 'upstream: ' + cmp1.upstream
puts 'revision: ' + cmp1.revision if cmp1.revision
puts cmp1.ver_string