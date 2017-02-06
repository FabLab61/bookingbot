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

COMMAND=${1:-run}

case $COMMAND in
	run)
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

	prove)
	build
	docker run --rm --name bookingbot --entrypoint prove fablab/bookingbot -l
	;;

	sh)
	build
	docker run -it --rm --name bookingbot --entrypoint /bin/bash fablab/bookingbot
	;;

	*)
	echo "Unknown command: $COMMAND" >&2
	echo "Usage: $0 [command]" >&2
	echo "	run     run bot (default)" >&2
	echo "	watch   run bot and restart it each time source files changed" >&2
	echo "	debug   run bot with debugger attached" >&2
	echo "	prove   run tests" >&2
	echo "	sh      run a shell in the container" >&2
	echo "	help    show this help and exit" >&2
	exit 1
	;;
esac
