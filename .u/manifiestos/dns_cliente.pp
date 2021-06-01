# Class: dnsconfig
#
#
class dnsconfig {

    file { '/etc/resolv.conf':
        ensure => file,
        content => "nameserver 1.1.1.1\n"
    }
}

class {"dnsconfig":}