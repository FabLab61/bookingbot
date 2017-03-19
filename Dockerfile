FROM fablab/bookingbot-dev
CMD ["bot.pl"]

# docker run --rm --name bookingbot -v $(pwd):/bookingbot pavelsr/bookingbot-dev bot.pl