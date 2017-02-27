FROM jruby:9.1.7.0-jre-alpine

RUN apk --update --no-cache add git openssh-client && \
    gem install bundler && \
    mkdir /hucpa

WORKDIR /hucpa

COPY hucpa.gemspec Gemfile Gemfile.lock ./

RUN bundle

COPY . ./
