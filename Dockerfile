FROM crystallang/crystal:nightly

# Add the app and build it
WORKDIR /app/
ADD . /app
ARG CRYSTAL_ENV=production
ENV CRYSTAL_ENV=production
RUN shards build --production --release --no-debug

# Run server by default
CMD ["bin/server"]
