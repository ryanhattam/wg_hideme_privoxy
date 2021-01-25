# using older alpine due to a temp issue resolving apks for newer
FROM alpine:3.12
RUN apk update
RUN apk upgrade
RUN apk add --no-cache ca-certificates privoxy runit

RUN apk add --no-cache libc6-compat

RUN wget https://github.com/rofl0r/microsocks/archive/v1.0.1.tar.gz

RUN apk add --no-cache make gcc musl-dev
RUN tar -xzvf v1.0.1.tar.gz \
    && cd microsocks-1.0.1 \
    && make \
    && make install \
    && apk del make gcc musl-dev

MAINTAINER alturismo alturismo@gmail.com
LABEL folk-maintainer="ryan@hattam.com.au"

# Timezone (TZ)
RUN apk update && apk add --no-cache tzdata
ENV TZ=Australia/Adelaide
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add Bash shell & dependancies
RUN apk add --no-cache bash busybox-suid su-exec

# Volumes
VOLUME /config

# Add Files
COPY hide.client.linux /usr/bin/
RUN chmod +x /usr/bin/hide.client.linux
COPY hideme.yaml /
COPY CA.pem /
COPY startups /startups

RUN find /startups -name run | xargs chmod u+x

# Add Expose Port
EXPOSE 8080 1080

# Command
CMD ["runsvdir", "/startups"]
