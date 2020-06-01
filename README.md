# puma-docker

This repository contains files which helps setting up a docker container with the software used by the PuMA-Coll.

It is based on the docker built by the nanograv collab: [nanograv-docker](https://hub.docker.com/r/nanograv/ipta-docker)

## Pre-requisites

It just needs docker running in your computer (see the [official docker webpage](docker.com))

## Creating puma-docker

First, clone or download this repository: `git clone git@github.com:PuMA-Coll/puma-docker.git`

Then in the terminal go to its location and run `docker build -t puma/docker-puma .`

Note: maybe your user is not part of the docker group. In such cases, either add your user to the group and logout
(and re-login) and try it again, or simply run any docker command with `sudo`.

## After installing

One cool thing about docker is the ability to share locations. Thus, you can link a folder in your tree-structure with
docker when you first run it. For example,

```
docker run -d -v /path/in/your/work/tree:/home/jovyan/work/shared -p 8888:8888 -p 2222:22 --name puma puma/docker-puma
```

This example will have you share the info you have in `/path/in/your/work/tree/` with docker.  It will also create an
instance of a running container (check that it is actually working with `docker ps`)

The next thing you need to do is connect with the docker to change the password of the user (named `jovyan`):

```
docker exec -it puma /bin/bash
```

You should have a new prompt that looks as follows,

[]: https://github.com/PuMA-Coll/puma-docker/blob/master/docker-prompt.png

Once in here, you can make yourself the root with the command `su`, and set a password by running `passwd jovyan`.

After that, logout of the docker: 'exit' (or Ctrl + d).

## Connect to docker

In order to connect with the docker, just run `ssh -XY -p 2222 jovyan@localhost`. It will ask you for the password
that you set up on the last step. And that's it! You have a running instance of the puma-docker with the features
we use.

## Notes

Remember that you can always stop the container with: `docker stop puma`

And also restart it with: `docker start puma`
