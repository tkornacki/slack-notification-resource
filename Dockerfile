FROM --platform=amd64 alpine:3.20

RUN apk add --no-cache curl bash jq gettext-dev

COPY check /opt/resource/check
COPY in    /opt/resource/in
COPY out   /opt/resource/out

ARG oauth_token
ENV SLACK_BOT_USER_OAUTH_TOKEN=$oauth_token

RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check
