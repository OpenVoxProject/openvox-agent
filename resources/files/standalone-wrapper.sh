#!/bin/sh

# If $PATH does not match a regex for /opt/puppetlabs/bin
if [ `expr "${PATH}" : '.*/opt/puppetlabs/bin'` -eq 0 ]; then
  # Add /opt/puppetlabs/bin to a possibly empty $PATH
  PATH="${PATH:+${PATH}:}/opt/puppetlabs/bin"
  export PATH
fi

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
