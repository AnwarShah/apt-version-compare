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
    is_valid_version?(@epoch, @upstream, @revision)

  end

  def to_s
    @ver_string
  end
  
  private
  def is_valid_version?(epoch, upstream, revision)

    # epoch can only be numbers
    unless epoch.match(/^[0-9]+$/)
      raise InvalidAptVersion.new('Invalid epoch')
    end

    # checking upstream
    # upstream can only be
    # 0-9,a-z,A-Z,+,.,- (if revision exits),~,: (if epoch exists)
    # should starts with digits

    if epoch.to_i != 0 && revision == '0' # only epoch exists
      valid_upstream_regex = /^[0-9]+[a-zA-Z0-9~.+:]+$/
    elsif epoch.to_i != 0 && revision != '0' # both epoch and revision
      valid_upstream_regex = /^[0-9]+[-a-zA-Z0-9~.+:]+$/
    elsif epoch.to_i == 0 && revision != '0' # only revision exists
      valid_upstream_regex = /^[0-9]+[-a-zA-Z0-9~.+]+$/
    else # neither epoch nor revision
      valid_upstream_regex = /^[0-9]+[a-zA-Z0-9~.+]+$/
    end

    unless upstream.match(valid_upstream_regex)
      raise InvalidAptVersion.new('Invalid upstream')
    end

    valid_revision_regex = /^[0-9]+[a-zA-Z0-9~.+]+$/
    unless revision.match( valid_revision_regex )
      raise InvalidAptVersion.new('Invalid revision')
    end

  end

end

class InvalidAptVersion < ArgumentError
  def initialize(error_msg)
    super error_msg
  end
end

cmp1 = AptPkg_VersionCompare.new('1.0+32-s1beta1~svn1245')
puts 'epoch ' + cmp1.epoch if cmp1.epoch
puts 'upstream ' + cmp1.upstream
puts 'revision ' + cmp1.revision if cmp1.revision
puts cmp1.ver_string