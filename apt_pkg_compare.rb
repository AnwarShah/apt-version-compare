class AptPkg_VersionCompare
  attr_reader :epoch, :upstream, :revision, :ver_string

  def initialize(ver_string)

    ver_string = ver_string.split(':') # is there an epoch?
    @epoch = ver_string.length == 2 ? ver_string[0] : '0'

    unless @epoch == '0' # has an epoch
      ver_string = ver_string[1].rpartition('-')
    else
      ver_string = ver_string[0].rpartition('-')
    end

    # if first part is not empty, then there is a revision
    unless ver_string[0].empty?
      @upstream = ver_string[0]
      @revision = ver_string[2] # last part
    else # otherwise, if empty
      @upstream = ver_string[2]
      @revision = '0'
    end


    # construct full version string
    @ver_string = "#{@epoch.to_s}:#{@upstream.to_s}"
    unless @revision == '0'
      @ver_string += "-#{@revision.to_s}"
    end

    # Check for version string validity
    unless is_valid_version?
      InvalidAptVersion.new('Invalid apt version string')
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

    # if there is a revision, the upstream can contain hyphen
    if @revision == '0'
      valid_version_regex = /^([0-9]+:)?([0-9]+[a-zA-Z0-9~.+-]*)(-[0-9]+[a-zA-Z0-9~.+]*)?$/
    else
      valid_version_regex = /^([0-9]+:)?([0-9]+[a-zA-Z0-9~.+]*)(-[0-9]+[a-zA-Z0-9~.+]*)?$/
    end

    # return true if matched with the most general rule
    return true if @ver_string.match(valid_version_regex)

  end

end

class InvalidAptVersion < ArgumentError
  def initialize(error_msg)
    super error_msg
  end
end

# cmp1 = AptPkg_VersionCompare.new('1.0+321beta1~svn1245')
# cmp1 = AptPkg_VersionCompare.new('29:0.29-3')
# puts 'epoch: ' + cmp1.epoch if cmp1.epoch
# puts 'upstream: ' + cmp1.upstream
# puts 'revision: ' + cmp1.revision if cmp1.revision
# puts cmp1.ver_string

# cmp1 = AptPkg_VersionCompare.new('1:1.4-p6-13.1')
cmp1 = AptPkg_VersionCompare.new('1:2.2cvs20100105-true-dfsg-6ubuntu1')
puts 'epoch: ' + cmp1.epoch if cmp1.epoch
puts 'upstream: ' + cmp1.upstream
puts 'revision: ' + cmp1.revision if cmp1.revision
puts cmp1.ver_string
