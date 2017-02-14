#!/bin/bash

killall -9 httpd
killall -9 node
killall -9 perl

set -e

cd $OPENSHIFT_REPO_DIR/bookingbot 

ln -sf bot.pl.json bot.json

git pull --ff-only

cpanm -n -l $OPENSHIFT_DATA_DIR/perl5 --installdeps .

node $OPENSHIFT_REPO_DIR/bookingbot/openshift/monitor.js &>> $OPENSHIFT_LOG_DIR/monitor.log &

perl -I$OPENSHIFT_DATA_DIR/perl5/lib/perl5 -I$OPENSHIFT_REPO_DIR/serikoff.lib -I$OPENSHIFT_REPO_DIR/bookingbot $OPENSHIFT_REPO_DIR/bookingbot/bot.pl &>> $OPENSHIFT_LOG_DIR/bookingbot.log &
