class fail2ban (
  $email     = $fail2ban::params::email,
  $whitelist = $fail2ban::params::whitelist
) inherits fail2ban::params {

  validate_string(hiera('email'))
  validate_array(hiera('whitelist'))

  fail2ban::email { '/etc/fail2ban/jail.conf':
    email      => $email,
    whitelists => $whitelist,
  }

  file { '/etc/fail2ban/jail.local':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'jail.local',
    source  => [
      "puppet:///modules/fail2ban/${::hostname}/etc/fail2ban/jail.local",
      'puppet:///modules/fail2ban/common/etc/fail2ban/jail.local'
    ],
    notify  => Service['fail2ban'],
    require => Package['fail2ban'],
  }

  package { 'fail2ban':
    ensure => present,
  }

  service { 'fail2ban':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      File['jail.conf'],
      File['jail.local'],
      Package['fail2ban']
    ],
  }
}