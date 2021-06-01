
FROM alpine:latest
LABEL maintainer="i.am.vansmak@gmail.com"
RUN apk update
RUN apk upgrade
# Dependencies
RUN apk add --no-cache ca-certificates
RUN apk add --no-cache curl
RUN apk add --no-cache bash busybox-suid su-exec
RUN apk update && apk add --no-cache tzdata
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Remove APK cache
RUN rm -rf /var/cache/apk/*

# Add xteve binary
ADD https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_arm64.zip /tmp/xteve_linux_arm64.zip

# Unzip the Binary
RUN mkdir -p /xteve
RUN unzip -o /tmp/xteve_linux_arm64.zip -d /xteve

# Clean up the .zip
RUN rm /tmp/xteve_linux_arm64.zip

# Add user for VLC and ffmpeg
RUN addgroup -S xteve && adduser -S xteve -G xteve

# Set executable permissions
RUN chmod +x /xteve/xteve
RUN chown xteve:xteve /xteve/xteve

# Set user contexts
USER xteve

#Create folder structure for backups and tmp files
RUN mkdir /home/xteve/.xteve/
RUN mkdir /home/xteve/.xteve/backup/
RUN mkdir /tmp/xteve

#Set Permission on folders
RUN chown xteve:xteve /home/xteve/.xteve/
RUN chown xteve:xteve /home/xteve/.xteve/backup/
RUN chown xteve:xteve /tmp/xteve

# Volumes
VOLUME /home/xteve/.xteve

# Expose Ports for Access
EXPOSE 34400

# Healthcheck
HEALTHCHECK --interval=30s --start-period=30s --retries=3 --timeout=10s \
  CMD curl -f http://localhost:34400/ || exit 1

# Entrypoint should be the base command
ENTRYPOINT ["/xteve/xteve"]

# Command should be the basic working
CMD ["-port=34400"]
