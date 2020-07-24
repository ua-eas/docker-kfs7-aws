#!/bin/bash
# Change end of Dockerfile to ENTRYPOINT /usr/local/bin/local-testing.sh for local testing in order to bypass the rice dependency

# Start rsyslog
/usr/sbin/rsyslogd -i /var/run/syslogd.pid -f /etc/rsyslog.conf -n &

touch /var/log/testing.log && chmod a+w /var/log/testing.log

# tail a log so container doesn't exit
tail -f /var/log/testing.log