FROM alpine:latest

# Install dependencies
RUN apk add --no-cache unzip ca-certificates

# Download PocketBase (v0.24.4)
ADD https://github.com/pocketbase/pocketbase/releases/download/v0.24.4/pocketbase_0.24.4_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/ && rm /tmp/pb.zip

# Expose default port
EXPOSE 8080

# Copy migrations and hooks from project folder
COPY ./pb_migrations /pb/pb_migrations
COPY ./pb_hooks /pb/pb_hooks

# Run PocketBase, binding to 0.0.0.0 and listening on Railway's dynamic PORT
CMD ["sh", "-c", "/pb/pocketbase serve --http=0.0.0.0:${PORT:-8080} --dir=/pb/pb_data"]
