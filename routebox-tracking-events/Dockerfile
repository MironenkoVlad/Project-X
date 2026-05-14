# Multi-stage build. Builder produces a static-ish binary; runtime carries it.
#
# TODO: scratch (or distroless/static) base image. The libc dependency
# from one of our transitive Go deps bit us on the scratch attempt last
# year and we never debugged it. Image is bigger than it needs to be.

FROM golang:1.21.13 AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# CGO disabled so the binary doesn't pull libpq dynamically (pgx is pure Go).
ENV CGO_ENABLED=0 \
    GOOS=linux

RUN go build -trimpath -ldflags="-s -w" -o /out/tracking-events ./cmd/server


FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /out/tracking-events /tracking-events

ENV PORT=8080
EXPOSE 8080

CMD ["/tracking-events"]
