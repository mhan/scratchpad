$build_reqs = ['autoconf',
               'build-essential',
               'pkg-config',
               'libtool',
]

Exec {
    path => [
        '/usr/local/bin',
        '/opt/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/bin',
        '/sbin'
    ]
}

Vcsrepo {
    require => [Package['git'], Exec['ssh know github']],
    user    => 'vagrant',
}

exec { 'add nodejs apt repo':
    command => 'curl -sL https://deb.nodesource.com/setup | bash -',
    unless  => 'which node',
    require => Exec['apt-get update'],
}

exec { 'apt-get update':}

package { 'git':
    ensure  => installed,
    require => Exec['apt-get update'],
}

package { 'zsh':
    ensure  => installed,
    require => Exec['apt-get update'],
}

package { 'nodejs':
    ensure  => installed,
    require => Exec['add nodejs apt repo'],
}

package { $build_reqs:
    ensure  => installed,
    require => Exec['apt-get update']
}

exec { 'ssh know github':
    command => 'ssh -Tv git@github.com -o StrictHostKeyChecking=no; echo Success',
    path    => '/bin:/usr/bin',
    user    => 'vagrant'
}

vcsrepo { "/home/vagrant/.dotfiles":
    ensure   => present,
    provider => git,
    source   => "git@github.com:mhan/dotfiles.git",
    require  => Package['git'],
}

exec { "chsh -s /usr/bin/zsh vagrant":
    require => Package['zsh'],
}

exec { "bash script/install":
    cwd     => '/home/vagrant/.dotfiles',
    user    => 'vagrant',
    require => [Package['git'], Vcsrepo['/home/vagrant/.dotfiles']],
}
