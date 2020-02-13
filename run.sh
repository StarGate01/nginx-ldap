#!/bin/bash

cat <> /tmp/logpipe 1>&2 &
nginx -g 'daemon off;'