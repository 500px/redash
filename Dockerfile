FROM node:10 as frontend-builder
MAINTAINER platform <platform@500px.com>
WORKDIR /go/src/github.com/500px/redash

#WORKDIR /frontend
COPY package.json package-lock.json /go/src/github.com/500px/redash/
RUN npm install

COPY . /go/src/github.com/500px/redash/
#COPY docker/* /go/src/github.com/500px/redash/
#COPY . .
#RUN npm run build
EXPOSE 5000

FROM redash/base:latest

# Controls whether to install extra dependencies needed for all data sources.
ARG skip_ds_deps

# We first copy only the requirements file, to avoid rebuilding on every file
# change.
COPY requirements.txt requirements_dev.txt requirements_all_ds.txt ./
RUN pip install -r requirements.txt -r requirements_dev.txt
RUN if [ "x$skip_ds_deps" = "x" ] ; then pip install -r requirements_all_ds.txt ; else echo "Skipping pip install -r requirements_all_ds.txt" ; fi

#COPY . /app
#COPY --from=frontend-builder /frontend/client/dist /app/client/dist
RUN chown -R redash /app
USER redash

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["server"]
