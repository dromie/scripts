#!/bin/bash -e
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh

TMPDIR=`mktemp -d`
export DB=$TMPDIR/db.db
echo "Testing dir $TMPDIR"
echo "DB=$TMPDIR/db.db"
sql "create table files (filename TEXT PRIMARY KEY NOT NULL, state INTEGER, mtime INTEGER)"

remove() {
  sql "UPDATE files SET state=1 WHERE filename='$1'"
}

findsort() {
    ${self_dir}/findsort.py $TMPDIR
}

assert() {
    MSG=$1
    LN=$2
    shift 2
    if ! "$@";then
        echo "Error: $MSG line: $LN"
        exit -1
    fi
}


assert "Empty DB should be 0" $LINENO test `filecount` -eq 0
findsort
assert "Empty Directory should be 0" $LINENO test `filecount` -eq 0


touch $TMPDIR/zero.mp4
findsort
assert "File with zero size should not appear" $LINENO test `filecount` -eq 0

TESTFILE1=$TMPDIR/test1.mp4
TESTFILE2=$TMPDIR/test2.mp4
echo "Test" >$TESTFILE1
touch --date=@1000000000 $TESTFILE1
findsort
assert "test1.mp4 should appear" $LINENO test `filecount` -eq 1
assert "test1.mp4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE1`" == "$TESTFILE1 20010909_034640" 

remove $TESTFILE1
findsort
assert "After remove it filecount should be 0" $LINENO test `filecount` -eq 0

echo "Test2" >$TESTFILE2
touch --date=@1030000000 $TESTFILE2
findsort
assert "test2.mp4 should appear" $LINENO test `filecount` -eq 1
assert "test2.mp4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20020822_090640" 

touch --date=@1040000000 $TESTFILE1
findsort
assert "test1.mp4 should reappear" $LINENO test `filecount` -eq 2
assert "test1.mp4 should reappear with fullpath with new date" $LINENO test "`files|grep $TESTFILE1`" == "$TESTFILE1 20021216_015320" 
assert "test2.mp4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20020822_090640" 

remove $TESTFILE2
findsort
assert "test2.mp4 should disappear" $LINENO test `filecount` -eq 1
assert "files should only contain test1.mp4 with fullpath with new date" $LINENO test "`files`" == "$TESTFILE1 20021216_015320" 

echo "Tests OK"
rm -rf $TMPDIR
