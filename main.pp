import 'variables.pp'


class glusterfs {
  ssh_authorized_key { 'vmhost01_key':
    name   => 'root@192.168.122.1',
    ensure => 'present',
    user   => 'root',
    type   => 'ssh-rsa',
    key    => '##Place your public key##',
  }

  yumrepo { 'glusterfs_repo':
    name     => 'glusterfs',
    descr    => 'Repository for GlusterFS 3.3',
    baseurl  => 'http://download.gluster.org/pub/gluster/glusterfs/3.3/LATEST/EPEL.repo/epel-6Server/x86_64/',
    enabled  => '1',
    gpgcheck => '0',
    before   => Package['glusterfs_server'],
  }

  exec { 'mkfs_data':
    path      => '/sbin',
    command   => "mkfs.ext4 -I 512 $data_device",
    unless    => "tune2fs -l $data_device",
    logoutput => true,
    before    => Mount['data_dir'],
  }

  file { '/data':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    ensure => directory,
    before => Mount['data_dir'],
  }

  mount { 'data_dir':
    name    => '/data',
    options => 'defaults',
    device  => $data_device,
    fstype  => 'ext4',
    ensure  => 'mounted',
  } 

  file { '/etc/sysconfig/iptables':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => "$manifest_dir/dist/iptables",
    notify  => Service['iptables'],
  }

  service { 'iptables':
    name      => 'iptables',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }

  service { 'rpcbind':
    name      => 'rpcbind',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => Package['nfstools'],
  }

  service { 'glusterd':
    name      => 'glusterd',
###    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => Package['glusterfs_server'],
  }

  package { 'nfstools':
    name   => [ 'rpcbind', 'nfs-utils' ],
    ensure => installed,
  }   

  package { 'glusterfs_server':
    name   => [ 'glusterfs-server', 'glusterfs-geo-replication', 'glusterfs-fuse' ],
    ensure => installed,
  }   
}

include 'glusterfs'
