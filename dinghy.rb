require 'formula'

DINGHY_VERSION='3.0.3'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  url  'https://github.com/codekitchen/dinghy.git', tag: "v#{DINGHY_VERSION}"
  head 'https://github.com/codekitchen/dinghy.git', branch: :master
  version DINGHY_VERSION

  attr_reader :user_home_dir

  def initialize(*a, &b)
    @user_home_dir = ENV.fetch("HOME")
    super
  end

  devel do
    url './'
  end

  depends_on 'docker'
  depends_on 'unfs3'
  depends_on 'dnsmasq'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", user_home_dir)
      s.gsub!("%UID%", Process.uid.to_s)
      s.gsub!("%GID%", Process.gid.to_s)
    end

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plist.
    inreplace(["dinghy.unfs.plist", "dinghy.dnsmasq.plist"]) do |s|
      s.gsub!("%PREFIX%", HOMEBREW_PREFIX)
      s.gsub!("%ETC%", prefix/"etc", false)
    end

    (prefix/"etc").install "dinghy-nfs-exports", "dinghy.unfs.plist", "dinghy.dnsmasq.plist"

    FileUtils.mkdir_p(var/"dinghy/vagrant")
    FileUtils.cp("vagrant/Vagrantfile", var/"dinghy/vagrant/Vagrantfile")

    bin.install "bin/dinghy"
    prefix.install "cli"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and services.
    EOS
  end
end
