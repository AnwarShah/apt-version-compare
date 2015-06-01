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
      InvalidAptVersion.new('Invalid apt version string')
    end

  end

  def to_s
    @ver_string
  end
  
  private
  def is_valid_version?

    # Note: I didn't add checking of colons in upstream when there is epoch,
    # As that is very very rare case

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
cmp1 = AptPkg_VersionCompare.new('12.2cvs:20100105-true-dfsg-6ubuntu1')
puts 'epoch: ' + cmp1.epoch if cmp1.epoch
puts 'upstream: ' + cmp1.upstream
puts 'revision: ' + cmp1.revision if cmp1.revision
puts cmp1.ver_string
