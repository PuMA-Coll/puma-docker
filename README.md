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

![prompt](https://github.com/PuMA-Coll/puma-docker/blob/master/docker-prompt.png "docker prompt")

Once in here, you can make yourself the root with the command `su`, and set a password by running `passwd jovyan`.

After that, logout of the docker: 'exit' (or Ctrl + d).

## Connect to docker

In order to connect with the docker, just run `ssh -XY -p 2222 jovyan@localhost`. It will ask you for the password
that you set up on the last step. And that's it! You have a running instance of the puma-docker with the features
we use.

## Notes

Remember that you can always stop the container with: `docker stop puma`

And also restart it with: `docker start puma`

To add other drives to the docker do this....

I've successfully mount /home/<user-name> folder of my host to the /mnt folder of the existing (not running) container. You can do it in the following way:

    Open configuration file corresponding to the stopped container, which can be found at /var/lib/docker/containers/99d...1fb/config.v2.json (may be config.json for older versions of docker).

    Find MountPoints section, which was empty in my case: "MountPoints":{}. Next replace the contents with something like this (you can copy proper contents from another container with proper settings):

"MountPoints":{"/mnt":{"Source":"/home/<user-name>","Destination":"/mnt","RW":true,"Name":"","Driver":"","Type":"bind","Propagation":"rprivate","Spec":{"Type":"bind","Source":"/home/<user-name>","Target":"/mnt"},"SkipMountpointCreation":false}}

or the same (formatted):

  "MountPoints": {
    "/mnt": {
      "Source": "/home/<user-name>",
      "Destination": "/mnt",
      "RW": true,
      "Name": "",
      "Driver": "",
      "Type": "bind",
      "Propagation": "rprivate",
      "Spec": {
        "Type": "bind",
        "Source": "/home/<user-name>",
        "Target": "/mnt"
      },
      "SkipMountpointCreation": false
    }
  }
  
  ## IAR FIL files

This data will be used by the .fil header file, from the .iar file

Telescope ID,

IAR-A1: 19, "IAR1", "A1", "m"

IAR-A2: 20, "IAR2", "A2", "o",

IAR-ROACH-A1: 21, "IAR1R", "R1", "r"

IAR-ROACH-A2: 22, "IAR2R", "R2", "s",

DSA-3: 24, "DSA3", "D3", "p",

CLTC: 25, "CLTC", "CL", "q",

Machine ID,

RTL_Filterbank: 23

IAR_ROACH_v1: 24

IAR_SNAP_v1: 25
