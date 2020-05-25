# puma-docker

This repository contains files which helps setting up a docker container with the software used by the PuMA-Coll.

It is based on the docker built by the nanograv collab: ![nanograv-docker](https://hub.docker.com/r/nanograv/ipta-docker)

## Pre-requisites

It just needs docker running in your computer (see the ![official docker webpage](docker.com))

## Creating puma-docker

First, clone or download this repository. Then in the terminal go to its location and run `docker build -t puma/docker-puma .`

## After installing

One cool thing about docker is the ability to share locations. Thus, you can link a folder in your tree-structure with docker
when you first run it. For example,

```
docker run -d -v /path/in/your/work/tree:/home/jovyan/work/shared -p 8888:8888 -p 2222:22 --name docker-puma puma/docker-puma
```

This example will have you share the info you have in `/path/in/your/work/tree/` with docker.  It will also create an instance
of a running container (check that it is actually working with `docker ps`)

Remember that you can always stop the container with: `docker stop docker-puma`

And also re-start with: `docker start docker-puma`

## Connect to docker

In order to connect, just run `ssh -XY -p 2222 jovyan@localhost`
