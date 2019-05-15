#!/bin/bash

echo "Starting puppet"
/etc/init.d/puppet-master start
/opt/puppetlabs/bin/puppet cert list
tail -f /dev/null
