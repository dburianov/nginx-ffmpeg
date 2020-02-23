#!/bin/bash

#
consul agent -data-dir=/etc/consul.d -config-dir=/etc/consul.d  -retry-join 10.239.110.194 --bootstrap-expect=1 &
/usr/local/nginx/sbin/nginx -g 'daemon off;'
/bin/bash

