#!/bin/bash

docker run --detach \
    --hostname puppet \
    --name puppet \
    --volume /Users/daniel.thompson/Git/personal/automation/docker/puppet/code:/etc/puppet/code \
    puppet
