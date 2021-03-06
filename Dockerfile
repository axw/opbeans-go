FROM golang:1.11
RUN go get -v github.com/gin-contrib/cache
RUN go get -v github.com/gin-contrib/cache/persistence
RUN go get -v github.com/gin-contrib/pprof
RUN go get -v github.com/gin-gonic/gin
RUN go get -v github.com/gomodule/redigo/redis
RUN go get -v github.com/jmoiron/sqlx
RUN go get -v github.com/pkg/errors
RUN go get -v github.com/sirupsen/logrus
RUN go get -v github.com/lib/pq
RUN go get -v github.com/mattn/go-sqlite3
WORKDIR /go/src/github.com/elastic/opbeans-go
COPY *.go /go/src/github.com/elastic/opbeans-go/
COPY db /go/src/github.com/elastic/opbeans-go/db
COPY vendor /go/src/github.com/elastic/opbeans-go/vendor
RUN go get -v

FROM gcr.io/distroless/base
COPY --from=opbeans/opbeans-frontend:latest /app/build /opbeans-frontend
COPY --from=0 /go/bin/opbeans-go /
COPY --from=0 /go/src/github.com/elastic/opbeans-go/db /
EXPOSE 8000

HEALTHCHECK \
  --interval=10s --retries=10 --timeout=3s \
  CMD ["/opbeans-go", "-healthcheck", "localhost:8000"]

CMD ["/opbeans-go", "-frontend=/opbeans-frontend", "-db=sqlite3:/opbeans.db"]
