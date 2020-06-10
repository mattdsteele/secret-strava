FROM ruby:2.7

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

EXPOSE 4567

COPY . .
RUN bundle install

ENV APP_ENV=production

CMD ruby ./src/server.rb
