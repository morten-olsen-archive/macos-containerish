#/bin/bash
set -e

export NAME=$1
export JAIL_LOCATION=$PWD/workspace/$NAME

mkdir -p ./images
rm -f ./images/$NAME.dmg
hdiutil create ./images/$NAME -volname $NAME -size 30000mb -fs HFS+
DISKMOUNT=$(hdid -nomount ./images/$NAME.dmg | awk '{print $1}' | sed -n 3p)
echo "Created disk $DISKMOUNT"
mkdir -p $JAIL_LOCATION
mount -t hfs $DISKMOUNT "$JAIL_LOCATION"

rm -rf files
echo "Adding minimal shell files"
cat ./minimal.files > files

echo "Adding executables"
EXECS="$(cat executables)"
for exec in $EXECS; do
    echo "... adding $exec"
    bash ./add-exec-to-image.sh $exec
done

echo "Copying to image"
mkdir -p $JAIL_LOCATION/bin
FILES="$(cat files)"
for file in $FILES; do
    [ -c $file ] && {
        mkdir -p "$(dirname $JAIL_LOCATION$file)" || {
            echo "ERROR: Cannot create parent dir for: $JAIL_LOCATION$file"
            exit 1
        }
        majmin="$(ls -l "$file" | awk '{print $5, $6}' | tr -d ,)"
        if [ ! -c $JAIL_LOCATION$file ]; then
            mknod $JAIL_LOCATION$file c $majmin || {
                echo "ERROR: Failed to create device node: $JAIL_LOCATION$file"
                exit 1
            }
        fi
    }
    [ -d $file ] && {
        mkdir -p $JAIL_LOCATION$file || {
            echo "ERROR: Failed to copy directory into jail: $JAIL_LOCATION$file"
            exit 1
        }
    }
    [ -f $file ] && {
        mkdir -p "$(dirname $JAIL_LOCATION$file)" || {
            echo "ERROR: Cannot create parent dir for: $JAIL_LOCATION$file"
            exit 1
        }
        cp $file $JAIL_LOCATION$file || {
                echo "ERROR: Failed to copy file into jail: $JAIL_LOCATION$file"
                exit 1
        }
    }
done

bash $2

umount "$JAIL_LOCATION"