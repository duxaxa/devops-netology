FROM elasticsearch:7.17.9
RUN mkdir -p /var/lib/data \
    && chown -R elasticsearch:root /var/lib/data
VOLUME [ "/var/lib/data" ]
COPY --chown=elasticsearch:root elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY --chown=elasticsearch:root jvm.options /usr/share/elasticsearch/config/jvm.options