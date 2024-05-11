# psi4-docker-utils
> Utilities to help build replicatable Psi4 docker images with various utilities for reproducible quantum chemistry calculations.

**Why?** -- So far, our research group has been having a very difficult time building Psi4. Each person's computer
has a different issue, and its difficult to reproduce things. So, this Docker container was written to provide a
*standard* environment for building Psi4. The idea is to first build this container, then use the container to build
Psi4. I know that Conda can make a venv, but this wasn't working properly for some team members. I personally was
having issues with cmake in builds, and for some reason I'm not having them in docker. At any rate, this is the first
way I was able to get this to build. This build process is loosely based on the Azure build process, which you cannot
run on your local system because Microsoft removed that functionality. So, this is a Dockerized version of that, which
you can use as a base for local reproducible builds, or easy local development. Interestingly, the Azure builds
include steps that are *not* in the official build docs. I have included what seems to be essential to run the build.

This repository builds several docker images:

**Note:** When using this in research work, **ALWAYS** explicitly specify a version (instead of `latest`) to enable
reproducible results!

**Note 2:** All files used to run the examples below are in the `example/` directory!

## Sub-images
### Base

This image can be used to run Psi4 directly, like so:

```
docker run -v .:/home/ubuntu/work/ nathanpennie/psi4-docker-utils:base-latest psi4 h2o.dat output.dat
```
* `-v .:/home/ubuntu/work/` - Any command runs in `/home/ubuntu/work/` *inside* the container. So, this gives Psi4
access to your local directory (`.`)
* `nathanpennie/psi4-docker-utils:jupyter-latest` - The docker image tag. Switch `latest` to your desired Psi4 version
branch tag. Make sure you have actually built this image first, or I have posted it to Docker Hub.
* Next follows the [Psi4 command itself](https://psicode.org/psi4manual/master/tutorial.html)

You should find an `output.dat`, among other things, in your current directory, which should have:
```
    Total Energy =                        -76.0266327350904589
```

Or, you can launch an interactive bash shell:

```
docker run -it -v .:/home/ubuntu/work/ nathanpennie/psi4-docker-utils:base-latest bash
```

* Adds `-it` for an interactive shell

### Jupyter

The Jupyter image starts a Jupyter Notebook server, so you can easily start using Psi4 in your calculations. It comes
pre-installed with `numpy`, `scipy`, `matplotlib`, and `pandas`. Additional packages can be installed by either:
1. (Preferred) Creating custom Docker images using `conda install`. You can simply modify
`Dockerfile.template-custom-jupyter` to do this easily, then use the existing `build.sh` to build. See below for usage
of `build.sh`.
2. Using `docker exec` to launch a shell and run `conda install`. These changes disappear once the Docker image stops.

**WARNING:** Be *absolutely sure* that you remember to bind mount the `/home/ubuntu/work/` directory (see below).
Otherwise, you will loose your work when the container stops. It would also be a good idea to double check that Jupyter
is actually saving correctly on your local filesystem where you expect it to.

I'd recommend running it with:
```
docker run -it -v .:/home/ubuntu/work nathanpennie/psi4-docker-utils:jupyter-latest
```
* `-it` - Makes the terminal interactive, and allows you to see the `token` URL
* `-v .:/home/ubuntu/work/` - This gives Jupyter access to your local directory (`.`). The local directory contents
should automatically appear in Jupyter.
* `nathanpennie/psi4-docker-utils:jupyter-latest` - The docker image tag. Switch `latest` to your desired Psi4 version
branch tag. Make sure you have actually built this image first, or I have posted it to Docker Hub.
* No additional command is necessary

Unfortunately, Jupyter doesn't know its IP address. You will need to substitute the IP address in the URL provided by
Jupyter with your Docker container's URL:
1. Start Jupyter, and take note of the `http://127.0.0.1:8888/...` URL
2. Use `docker ps` to find the container you just started
3. Run `docker inspect --format='{{json .NetworkSettings.IPAddress}}' <CONTAINER NAME>` to get the IP
4. Replace `127.0.0.1` with this new IP
5. If your browser hangs, check your firewall. If your browser can't connect/complains about bad data, check that your
browser didn't change the URL to `https`.

I need to find a decent workaround, but for the time being, that will have to work.

There is an example notebook in the `example` directory. Try running it to get the H2O energy again.

### Snakemake
This image comes with `snakemake`, as well as `numpy`, `scipy`, `matplotlib`, and `pandas`. It's useful for generating
reproducible calculations. It can be run like so:
```
docker run -it -v .:/home/ubuntu/work nathanpennie/psi4-docker-utils:jupyter-latest snakemake -c1 <your args>
```
The arguments for this will depend on your Snakefile. See the [Snakemake docs](https://snakemake.readthedocs.io/en/stable/).

## Building

The build script can help build:
```
./build.sh base
# OR... (adds the :base-latest tag!)
./build.sh base --tag-latest
# OR...
./build.sh jupyter --tag-latest
# ...
```

Anything named `Dockerfile.<ANYTHING>` is fair game to pass to `build.sh` -- I.e, you can run `build.sh base` because
`Dockerfile.base` exists. You can make your own dockerfiles and build these, too, they'll just be tagged with my docker
hub username. This is OK for local development, but I should probably fix this somehow.

The build script works by finding the branch version from the `.gitmodules` file, and appending it to the base tag name.
**This way, updating the submodule branch is all you need to do to support a new Psi4 version** assuming the build
doesn't end up breaking between versions (still quite possible).

