FROM oven/bun:1.4.4

USER root
ENV HOME=/root

RUN bun install -g github:garrytan/gbrain#stable

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8787

ENTRYPOINT ["/entrypoint.sh"]
