FROM alpine:3.3

# Compile protobuf, modified from pulcy/protoc
RUN mkdir -p /protobuf \
  && buildDeps='autoconf automake curl g++ git libtool make' \
  && apk add -U $buildDeps \
  && rm -rf /var/cache/apk/* \
  && git clone https://github.com/google/protobuf.git /protobuf \
  && cd /protobuf \
  && git checkout 5e933847cc9e7826f1a9ee8b3dc1df4960b1ea5d \
  && ./autogen.sh \
  && ./configure --prefix=/usr \
  && make \
  && make install \
  && rm -rf /protobuf \
  && apk del $buildDeps \
  && apk add -U libstdc++ # this gets unintentionally removed along with the build deps

# Install Ruby
RUN apk add -U ruby ruby-rake ruby-io-console ruby-bigdecimal libstdc++ tzdata

# Install Ruby build tools
RUN apk add -U gcc libc-dev make ruby-dev

# Install bundler
RUN gem install bundler --no-ri --no-rdoc \
  && rm -r /root/.gem \
  && find / -name '*.gem' | xargs rm

# Gems don't need docs by default
RUN echo "gem: --no-ri --no-rdoc" > /etc/gemrc

# Local gem install by convention
RUN bundle config path vendor/bundle/`ruby --version | cut -d " " -f 2` \
  && bundle config bin vendor/bundle/`ruby --version | cut -d " " -f 2`/bin

CMD ["sh"]