FROM alpine:3.16.0 AS permissions-giver

# Make sure docker-entrypoint.sh is executable, regardless of the build host.
WORKDIR /out
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

FROM golang:1.18.3-alpine3.15 AS builder

# Build wuzz
WORKDIR /out
COPY . .
RUN go build .

FROM alpine:3.16.0 AS organizer

# Prepare executables
WORKDIR /out
COPY --from=builder /out/wuzz .
COPY --from=permissions-giver /out/docker-entrypoint.sh .

FROM alpine:3.16.0 AS runner
WORKDIR /wuzz
COPY --from=organizer /out /usr/local/bin
ENTRYPOINT [ "docker-entrypoint.sh" ]
