name 'torque'
maintainer 'David Brown'
maintainer_email 'dmlb2000@gmail.com'
license 'All rights reserved'
description 'Installs/Configures torque'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.1'

supports 'fedora', '>= 20'
supports 'redhat', '~> 5'
supports 'scientific', '~> 5'
supports 'centos', '~> 5'

depends 'yum-epel'
depends 'yum'
depends 'auto-update'
depends 'hostsfile'
depends 'hostname'
