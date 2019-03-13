INSTANCE_NAME=test
IMAGE_NAME=xcode

mkdir -p ./instances/$INSTANCE_NAME/workspace
if [ ! -f ./instances/$INSTANCE_NAME/data ]; then
echo "create"
  hdiutil create ./instances/$INSTANCE_NAME/data -volname $INSTANCE_NAME -size 100mb -fs HFS+
fi
IMAGEDISKMOUNT=$(sudo hdid -nomount ./images/$IMAGE_NAME.dmg | awk '{print $1}' | sed -n 3p)
DATADISKMOUNT=$(hdid -nomount ./instances/$INSTANCE_NAME/data.dmg | awk '{print $1}' | sed -n 2p)
echo "Using disk $IMAGEDISKMOUNT and $DATADISKMOUNT"
sudo mount -t hfs  -o union,ro $IMAGEDISKMOUNT ./instances/$INSTANCE_NAME/workspace
sudo mount -t hfs  -o union $DATADISKMOUNT ./instances/$INSTANCE_NAME/workspace

EXECS="$(cat startup.sh)"
for exec in $EXECS; do
    echo "... adding $exec"
    chroot ./instances/$INSTANCE_NAME/workspace $exec
done
sudo chroot ./instances/$INSTANCE_NAME/workspace
echo "Unmounting"
sudo umount "./instances/$INSTANCE_NAME/workspace"