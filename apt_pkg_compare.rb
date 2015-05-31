class AptPkg_VersionCompare
  attr_reader :epoch, :upstream, :revision, :ver_string

  def initialize(ver_string)
    ver_string = ver_string.split(':') # is there an epoch?
    @epoch = ver_string.length > 1 ? ver_string[0] : '0'

    unless @epoch == '0' # has an epoch
      ver_string = ver_string[1].split('-')
    else
      ver_string = ver_string[0].split('-')
    end
    @upstream = ver_string[0]
    @revision = ver_string.length > 1 ? ver_string[1] : '0'

    # construct full version string
    @ver_string = "#{@epoch.to_s}:#{@upstream.to_s}"
    unless @revision == '0'
      @ver_string += "-#{@revision.to_s}"
    end

  end

  def to_s
    @ver_string
  end

end

cmp1 = AptPkg_VersionCompare.new('4:1.0~beta1~svn1245')
puts cmp1.epoch
puts cmp1.upstream
puts cmp1.revision
puts cmp1.ver_string