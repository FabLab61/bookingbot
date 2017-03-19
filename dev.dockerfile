# File for auto building of pavelsr/bookingbot-dev image
# Run build with
# docker build -t fablab/bookingbot-dev -f dev.dockerfile . 
# Run container with
# docker run --rm --name bookingbot -v $(pwd):/bookingbot pavelsr/bookingbot-dev

FROM perl:5.24.0

COPY cpanfile ./

RUN cpanm --installdeps .
RUN rm cpanfile

WORKDIR /bookingbot

VOLUME ["/bookingbot"]

ENTRYPOINT ["perl"]

LABEL maintainer "Pavel Serikov <pavelsr@cpan.org>"
