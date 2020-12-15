FROM avvo/alpine:3.5
RUN /build/ruby 2.7.2

ENV TZ=America/Los_Angeles

WORKDIR /srv/kafkamon

COPY Gemfile* ./

ARG PACKAGECLOUD_READ_TOKEN
RUN PACKAGECLOUD_READ_TOKEN=$PACKAGECLOUD_READ_TOKEN \
  /build/bundle-install \
  --path=vendor/bundle \
  --binstubs=binstubs \
  --deployment \
  --without development test

COPY . ./

ENTRYPOINT ["avvoenv", "exec"]
CMD ["bundle", "exec", "rackup"]
