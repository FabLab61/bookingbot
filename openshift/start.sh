#!/bin/bash

cd $OPENSHIFT_REPO_DIR/bookingbot 

git stash
git pull
git stash pop

cpanm -n -l $OPENSHIFT_DATA_DIR/perl5 --installdeps .

killall -9 httpd
killall -9 node
node $OPENSHIFT_REPO_DIR/bookingbot/openshift/monitor.js &>> $OPENSHIFT_LOG_DIR/monitor.log &

perl -I$OPENSHIFT_DATA_DIR/perl5/lib/perl5 -I$OPENSHIFT_REPO_DIR/serikoff.lib -I$OPENSHIFT_REPO_DIR/bookingbot $OPENSHIFT_REPO_DIR/bookingbot/bot.pl &>> $OPENSHIFT_LOG_DIR/bookingbot.log &
