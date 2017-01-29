FROM perl:5.24.0

MAINTAINER Denis T. <dev@denis-it.com>

WORKDIR /usr/src/bookingbot

COPY cpanfile ./

RUN cpanm --installdeps . \
	&& git clone https://bitbucket.org/serikov/serikoff.lib.git

COPY . .

ENTRYPOINT ["perl"]
