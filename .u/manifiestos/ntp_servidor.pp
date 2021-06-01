# Class: ntpconfig
#
#
class ntpconfig {

    $service_name = $facts['os']['family'] ? {
        'Debian'  => 'ntp',
        default   => 'ntpd',
    }

    package { 'ntp':
        ensure => present,   
    }
    
    $ntp_file =  "/etc/$service_name.conf"
    file { $ntp_file:
        ensure => present,
        content => "server 3.es.pool.ntp.org\n"
    }

    service { $service_name :
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        # pattern    => 'ntp',
    }
}

class {"ntpconfig":}