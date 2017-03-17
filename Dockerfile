FROM perl:5.24.0

MAINTAINER Denis T. <dev@denis-it.com>

WORKDIR /usr/src/bookingbot

COPY cpanfile ./

RUN cpanm --installdeps --verbose --self-upgrade . \

COPY . .

ENTRYPOINT ["perl"]
