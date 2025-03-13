project 'openvox-agent-standalone' do |proj|
  platform = proj.get_platform
  agent_branch = 'main'
  proj.setting(:is_standalone, true)
  # Settings that were defined in puppet-runtime that we aren't using here
  proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d") # If we add Windows, add C:\Windows\Temp\
  proj.setting(:prefix, "/opt/puppetlabs/puppet")
  proj.setting(:logdir, "/var/log/puppetlabs")
  proj.setting(:piddir, "/run/puppetlabs")
  proj.setting(:host_ruby, "/usr/bin/ruby")
  proj.setting(:bindir, "/opt/puppetlabs/puppet/bin")
  proj.setting(:ruby_vendordir, "/usr/lib/ruby/vendor_ruby")
  proj.setting(:datadir, "/opt/puppetlabs/puppet/share")
  proj.setting(:mandir, "/opt/puppetlabs/puppet/share/man")
  proj.setting(:gem_home, "$(/usr/bin/env gem environment gemhome)")
  proj.setting(:sysconfdir, "/etc/puppetlabs")
  proj.setting(:install_root, "/opt/puppetlabs")
  proj.setting(:link_bindir, "/opt/puppetlabs/bin")

  if platform.is_macos?
    proj.extra_file_to_sign File.join(proj.bindir, 'puppet')
    proj.extra_file_to_sign File.join(proj.bindir, 'wrapper.sh')
    proj.signing_hostname 'osx-signer-prod-3.delivery.puppetlabs.net'
    proj.signing_username 'jenkins'
    proj.signing_command 'security -q unlock-keychain -p \$$OSX_SIGNING_KEYCHAIN_PW \$$OSX_SIGNING_KEYCHAIN; codesign --timestamp --keychain \$$OSX_SIGNING_KEYCHAIN -vfs \"\$$OSX_CODESIGNING_CERT\"'
  end

  if platform.is_fedora? || platform.name =~ /el-10/
    proj.package_override("# Disable check-rpaths since /opt/* is not a valid path\n%global __brp_check_rpaths %{nil}")
    proj.package_override("# Disable the removal of la files, they are still required\n%global __brp_remove_la_files %{nil}")
  end

  proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet'))
  proj.setting(:puppet_codedir, File.join(proj.sysconfdir, 'code'))

  # Target directory for vendor modules
  proj.setting(:module_vendordir, File.join(proj.prefix, 'vendor_modules'))

  # Used to construct download URLs for forge modules in _base-module.rb
  proj.setting(:forge_download_baseurl, "https://forge.puppet.com/v3/files")

  proj.setting(:service_conf, File.join(proj.install_root, 'service_conf'))

  proj.description "The standalone OpenVox Agent package contains only Puppet, and relies on system packages for dependencies."
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Vox Pupuli <openvox@voxpupuli.org>"
  proj.homepage "https://voxpupuli.org"
  proj.target_repo "openvox8"

  if platform.is_solaris?
    proj.identifier "voxpupuli.org"
  elsif platform.is_macos?
    proj.identifier "org.voxpupuli"
  end

  # Set package version, for use by Facter in creating the AIO_AGENT_VERSION fact.
  proj.setting(:package_version, proj.get_version)

  proj.component "puppet"
  proj.component "wrapper-script"

  # Including headers can make the package unacceptably large; This component
  # removes files that aren't required.
  # Set the $DEV_BUILD environment variable to leave headers in place.
  #proj.component "cleanup"

  unless ENV['DEV_BUILD'].to_s.empty?
    proj.settings[:dev_build] = true
  end

  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.link_bindir
  proj.directory proj.logdir unless platform.is_windows?
  proj.directory proj.piddir unless platform.is_windows? || platform.is_solaris?
  if platform.is_windows? || platform.is_macos?
    proj.directory proj.bindir
  end

  # make sure we can replace puppet-agent in place for the rename, and you
  # only get either this standalone package or the AIO, not both.
  proj.replaces 'puppet-agent'
  proj.replaces 'openvox-agent'
  proj.conflicts 'puppet-agent'
  proj.conflicts 'openvox-agent'

  # To be updated for rpms
  proj.requires 'init-system-helpers'
  proj.requires 'adduser'
  proj.requires 'debconf'
  proj.requires 'facter'
  proj.requires 'hiera'
  proj.requires 'ruby'
  proj.requires 'ruby-augeas'
  proj.requires 'ruby-concurrent'
  proj.requires 'ruby-deep-merge'
  proj.requires 'ruby-semantic-puppet'
  proj.requires 'ruby-shadow'
  proj.requires 'ruby-sorted-set'
end
