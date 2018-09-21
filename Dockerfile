FROM crystallang/crystal:nightly

# Add the app and build it
WORKDIR /app/
ADD . /app
ARG APP_ENV=production
ENV APP_ENV=production
RUN shards build --production --release --no-debug

# Run server by default
CMD ["bin/server"]
