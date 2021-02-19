FROM debian:stable-slim

LABEL maintainer="kyle@bywatersolutions.com"

ENV DEBUG 0
ENV KOHACLONE /kohaclone
ENV PERL5LIB $KOHACLONE
ENV PATH $PATH:/app/bin

WORKDIR /app
ADD . /app

RUN apt-get -y update \
    && apt-get -y install \
      vim \
      git-core \
      cpanminus \
      libmodern-perl-perl \
      libxml-simple-perl \
      libyaml-perl \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/*
RUN cpanm Term::SimpleColor
RUN git clone --depth 1 https://git.koha-community.org/Koha-community/Koha.git /kohaclone_tmp
RUN mkdir -p $KOHACLONE/C4/SIP $KOHACLONE/misc 
RUN cp -ar /kohaclone_tmp/C4/SIP/. $KOHACLONE/C4/SIP/.
RUN cp -ar /kohaclone_tmp/misc/sip_cli_emulator.pl $KOHACLONE/misc/.
RUN rm -rf /kohaclone_tmp
