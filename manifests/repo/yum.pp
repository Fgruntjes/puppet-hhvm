# == Class: hhvm::repo::yum
#
# Configure yum repo
#
# === Parameters
#
# [*gpg_key_path*]
#   location of the yum repository gpg key
#
# === Variables
#
# No variables
#
# === Examples
#
#  include hhvm::repo::yum
#
# === Authors
#
# Freek Gruntjes <fgruntjes@emico.nl>
#
# === Copyright
#
# See LICENSE file
#
class hhvm::repo::yum(
  $gpg_key_path = "/etc/pki/rpm-gpg/RPM-GPG-KEY-gleez",
) {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  if ($ensure == 'present' or $ensure == true) {
    file { $gpg_key_path:
      source => 'puppet:///modules/hhvm/RPM-GPG-KEY-PGDG',
      before => Yumrepo['yum.postgresql.org']
    }

    yumrepo { 'gleez':
      descr    => "Gleez repo - \$basearch",
      baseurl  => "ttp://yum.gleez.com/6/$basearch/",
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG",
    }

    Yumrepo['gleez'] -> Package<|tag == 'hhvm'|>
  } else {
    yumrepo { 'gleezg':
      enabled => absent,
    }->
    file { $gpg_key_path:
      ensure => absent,
    }
  }
}
