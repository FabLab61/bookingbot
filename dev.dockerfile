# File for auto building of pavelsr/bookingbot image

FROM perl:5.24.0

WORKDIR /bookingbot
VOLUME ["/bookingbot"]

COPY cpanfile ./

RUN cpanm --installdeps .

ENTRYPOINT ["perl"]

CMD ["bot.pl"]

LABEL maintainer "Pavel Serikov <pavelsr@cpan.org>"