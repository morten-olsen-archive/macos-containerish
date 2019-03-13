function DerefSymLink() {
    [ -L "$1" ] || { echo "$1"; return; }
    local TARGET="$(readlink "$1")"
    [ -n "$TARGET" ] || { echo "$1"; return; }
    DerefSymLink "$TARGET"
}

function recurse() {
  [ $# -ne 1 ] && {
    echo "usage: $0 EXECUTABLE"
    exit 1
  }
  function SetUnion() {
    echo -n $(echo $1 $2 | tr ' ' '\n' | sort -u)
  }
  function SetSize() {
    [ -z "$*" ] && echo 0 || echo $(echo $* | tr ' ' '\n' | wc -l)
  }
  function SetDiff() {
    local rx="$(echo $2 | tr ' ' '\n' |  sed -e 's/^/^/;s/$/$/;s/+/\\+/g' |
                tr '\n' '|' | sed -e 's/|$//')"
    echo $1 | tr ' ' '\n' | egrep -v "$rx"
  }
  TOCHECK="$1"
  CHECKED=""
  while true; do
    TOCHECK_SIZE=$(SetSize $TOCHECK)
    [ $TOCHECK_SIZE -eq 0 ] && break
    for tc in $TOCHECK; do
      DEPS="$(otool -L $tc | fgrep -v ':' | cut '-d(' -f1)"
      DEPSNC="$(SetDiff "$DEPS" "$CHECKED")"
      TOCHECK="$TOCHECK $DEPSNC"
      CHECKED="$CHECKED $tc"
      TOCHECK="$(SetDiff "$TOCHECK" "$tc")"
    done
  done
  echo $CHECKED | tr ' ' '\n' | sort -u
}

RealExec="$(DerefSymLink "$0")"
RealExecDir="$(dirname "$RealExec")"
OriginalPWD="$(pwd -P)"
cd "$RealExecDir"
[ $# -ne 1 ] && {
    echo "usage: $0 EXECUTABLE"
    exit 1
}
[ -f "$1" ] || {
    echo "ERROR: Not found: $1"
    exit 1
}
ORIG="$(cat files)"
NEW="$(recurse $1)"
echo "$ORIG $NEW" | tr ' ' '\n' | egrep -v '^\s*$' | sort -u >files