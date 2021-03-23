FROM google/cloud-sdk:alpine
MAINTAINER somjade Keswongrot <somjade.k@live.com>

COPY usr/bin/ /usr/bin/
COPY lifecycle.json /lifecycle.json
COPY sql/ /sql/
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /usr/bin/ /docker-entrypoint.sh

VOLUME ["/.config"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
