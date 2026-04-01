# ELISIM_DOCKER


#### Build

Simple build:

```shell
docker build -t eliterobots/elisim_cs:latest -f Dockerfile .
```

Build with proxy:

```shell
docker build --build-arg HTTP_PROXY=http://host.docker.internal:7890 --build-arg HTTPS_PROXY=http://host.docker.internal:7890 -t eliterobots/elisim_cs:latest -f Dockerfile .
```

#### RUN

Expose port:

```shell
docker run --rm -it  -p 22:22 -p 5900:5900 -p 6080:6080 -p 2344:2344 --net elisim_net  --ip 192.168.200.101 --name elisim eliterobots/elisim_cs:latest
      

```

Expose port, mount volume and create network:

```shell
docker run --rm -it  -p 22:22 -p 5900:5900 -p 6080:6080 -p 2344:2344 --net elisim_net  --ip 192.168.200.101  -v $HOME/.elisim/plugins:/home/elite/EliRobot/.plugins -v $HOME/.elisim/program:/home/elite/EliRobot/program --name elisim eliterobots/elisim_cs:latest
```



