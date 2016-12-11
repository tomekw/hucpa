FROM jruby:9.1.6.0-jre-alpine

RUN apk --update --no-cache add git && \
    mkdir /hucpa

WORKDIR /hucpa

COPY hucpa.gemspec Gemfile Gemfile.lock ./

RUN gem install bundler && bundle

COPY . ./
