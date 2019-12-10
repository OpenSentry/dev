#!/bin/sh

cd $SRC

# This will exec the CMD from your Dockerfile, i.e. "npm start"
exec "$@"
