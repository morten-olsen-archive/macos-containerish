# MacOS Docker-ish

Proff of concept for creating "containers" on MacOS. Jail code is based on https://github.com/skissane/mkjail
As for docker compatability and approach like https://github.com/jkingyens/docker4xcode is going to be used
This is only a limited sandbox and does not do network seperation

## Creating images

Start by creating a build script, in our case we create a script `image.sh`
```
cp -r xcode.app $JAIL_LOCATION/xcode.app
```
as well as a list of desired system executables inside `./executables`

To create the actual image run `sudo ./make-image xcode image.sh`, which will generate `images/xcode.dmg`

## Using container

Containers mount both the created image as read only and a new empty image (`./instances/<NAME>/data`) as read write using union fs (`./instances/<NAME>/workspace`), and uses `chroot` to execute commands inside the new root
To run a container `./exec.sh <NAME> <IMAGE> <SCRIPT>`

**Example**

_run.sh_
```
echo "Hello World"
```

`./exec text xcode run.sh`

## TODO

- [ ] post action cleanup
- [ ] docker compatible server application
- [ ] multilayer images