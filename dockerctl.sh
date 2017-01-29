#!/bin/bash

function build {
	docker build -t fablab/bookingbot .
}

function runwatch {
	while inotifywait -e attrib ./*.p? ./tests/*.p?; do
		docker stop bookingbot &> /dev/null
		./docker_build_and_run.sh &
	done
}

COMMAND=${1:-regular}

case $COMMAND in
	regular)
	build
	docker run --rm --name bookingbot fablab/bookingbot bot.pl
	;;

	watch)
	build
	runwatch
	;;

	debug)
	build
	docker run -it --rm --name bookingbot fablab/bookingbot -d bot.pl
	;;

	tests)
	build
	docker run --rm --name bookingbot fablab/bookingbot ./tests/RecordTimeParser.pl
	;;

	*)
	echo "Unknown command: $COMMAND" >&2
	echo "Usage: $0 [command]" >&2
	echo "	regular	run bot in regular mode (default)" >&2
	echo "	watch	run bot in regular mode and restart it each time source files changed" >&2
	echo "	debug	run bot with debugger attached" >&2
	echo "	tests	run tests" >&2
	exit 1
	;;
esac
