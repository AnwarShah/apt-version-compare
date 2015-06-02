require 'apt_version_analyzer'

module AptVersionCompare

  def compare_versions(ver1, ver2)
    ver1_Obj = AptPkg_VersionAnalyzer.new(ver1)
    ver2_Obj = AptPkg_VersionAnalyzer.new(ver2)

    # extract info from version string
    @epoch1 = ver1_Obj.epoch
    @upstream1 = ver1_Obj.upstream
    @revision1 = ver1_Obj.revision

    @epoch2 = ver2_Obj.epoch
    @upstream2 = ver2_Obj.upstream
    @revision2 = ver2_Obj.revision

  end

end