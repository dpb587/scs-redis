class scs (
    $redis_options = {}
) {
    group {
        'scs' :
            ensure => present,
            gid => 1010,
            ;
    }

    user {
        'scs' :
            ensure => present,
            gid => 1010,
            shell => '/bin/false',
            uid => 1010,
            require => [
                Group['scs'],
            ],
            ;
    }

    exec {
        'apt-source:rwky/redis:key' :
            command => '/usr/bin/apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5862E31D',
            ;
        'apt-source:rwky/redis' :
            command => '/bin/echo "deb http://ppa.launchpad.net/rwky/redis/ubuntu precise main" >> /etc/apt/sources.list',
            unless => '/bin/grep "deb http://ppa.launchpad.net/rwky/redis/ubuntu precise main" /etc/apt/sources.list',
            require => [
                Exec['apt-source:rwky/redis:key'],
            ],
            ;
        'apt-update' :
            command => '/usr/bin/apt-get update',
            require => [
                Exec['apt-source:rwky/redis'],
            ],
            ;
        '/usr/bin/easy_install supervisor' :
            creates => '/usr/bin/supervisord',
            require => [
                Package['python-setuptools'],
            ],
            ;
    }

    file {
        "/scs/etc" :
            ensure => directory,
            ;
        "/scs/etc/supervisor.conf" :
            ensure => file,
            content => template('scs/supervisor/supervisor.conf.erb'),
            ;
        "/scs/etc/supervisor.d" :
            ensure => directory,
            ;
        "/scs/var" :
            ensure => directory,
            ;
        "/scs/var/log" :
            ensure => directory,
            ;
        "/scs/var/log/supervisord" :
            ensure => directory,
            ;
        "/scs/var/run" :
            ensure => directory,
            ;
        "/scs/var/run/supervisord" :
            ensure => directory,
            ;

        "/scs/etc/redis" :
            ensure => directory,
            ;
        "/scs/etc/redis/redis.conf" :
            ensure => file,
            content => template('scs/redis/redis.conf.erb'),
            ;
        "/scs/etc/supervisor.d/redis.conf" :
            ensure => file,
            content => template('scs/redis/supervisor.conf.erb'),
            ;
        "/scs/var/log/redis" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
        "/scs/var/run/redis" :
            ensure => directory,
            owner => 'scs',
            group => 'scs',
            ;
    }

    package {
        'redis-server' :
            ensure => installed,
            require => [
                Exec['apt-source:rwky/redis'],
                Exec['apt-update'],
            ],
            ;
        'python-setuptools' :
            ensure => installed,
            require => [
                Exec['apt-update'],
            ],
            ;
    }
}
