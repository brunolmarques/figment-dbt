FROM postgres:16.4-alpine
ENV POSTGRES_PASSWORD postgres
ENV POSTGRES_DB figment_db
ENV POSTGRES_USER postgres
COPY init-db.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh
EXPOSE 5432
