FROM alpine:3.7

RUN apk update
RUN apk add curl
RUN apk add bash

#
# Postgres
#

RUN apk add postgresql-client

# Ensure entrypoint.sh has unix style line endings, or else bash will fail to execute it
COPY entrypoint.sh /tmp.sh
RUN tr -d '\015' < tmp.sh > entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN rm /tmp.sh

ENTRYPOINT ["./entrypoint.sh"]
