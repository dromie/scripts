#!/bin/bash -e
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh

TMPDIR=`mktemp -d`
cp ${self_dir}/test_curl $TMPDIR/curl
chmod +x $TMPDIR/curl
export PATH=$TMPDIR:$PATH
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

upload() {

    DIR=$TMPDIR FTP=9.9.9.9 ${self_dir}/upload
}

reset_mock_curl() {
    $TMPDIR/curl reset
}

get_mock_curl_calls() {
    $TMPDIR/curl dump
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

test_file() {
    echo "Test" >$1
    touch --date=@$2 $1
}

reset_mock_curl

assert "Empty DB should be 0" $LINENO test `filecount` -eq 0
findsort
assert "Empty Directory should be 0" $LINENO test `filecount` -eq 0


touch $TMPDIR/zero.mp4
upload
assert "File with zero size should not appear" $LINENO test `filecount` -eq 0

TESTFILE1=$TMPDIR/test1.mp4
TESTFILE2=$TMPDIR/test2.mp4
TESTFILE3=$TMPDIR/test3.mp4
TESTFILE4=$TMPDIR/test4.mp4
TESTFILE5=$TMPDIR/test5.mp4
TESTFILE6=$TMPDIR/test6.mp4
test_file $TESTFILE1 1000000000
upload
assert "test1.mp4 should appear" $LINENO test `filecount` -eq 1
assert "test1.mp4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE1`" == "$TESTFILE1 20010909_034640" 


test_file $TESTFILE2 1040000000
test_file $TESTFILE3 1040000001
test_file $TESTFILE4 1040000002
test_file $TESTFILE5 1040000003

upload
assert "After upload it filecount should be 4" $LINENO test `filecount` -eq 4
assert "$TESTFILE1 should be uploaded" $LINENO test "`get_mock_curl_calls|grep -c \"$TESTFILE1.*ftp://.*20010909_034640\"`" -eq 1
assert "$TESTFILE1 should appear with fullpath" $LINENO test "`all_files|grep $TESTFILE1`" == "$TESTFILE1 20010909_034640" 
assert "$TESTFILE1 should not be in uploadable state" $LINENO test "`files|grep -c $TESTFILE1`" -eq 0 
assert "$TESTFILE2 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20021216_015320" 
assert "$TESTFILE3 should appear with fullpath" $LINENO test "`files|grep $TESTFILE3`" == "$TESTFILE3 20021216_015321" 
assert "$TESTFILE4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE4`" == "$TESTFILE4 20021216_015322" 
assert "$TESTFILE5 should appear with fullpath" $LINENO test "`files|grep $TESTFILE5`" == "$TESTFILE5 20021216_015323" 

reset_mock_curl
test_file $TESTFILE1 1040000000
upload

assert "$TESTFILE1 should be reuploaded with new filename" $LINENO test "`get_mock_curl_calls|grep -c \"$TESTFILE1.*ftp://.*20021216_015320\"`" -eq 1
assert "$TESTFILE1 should be reuploaded with new filename, not with old" $LINENO test "`get_mock_curl_calls|grep -c \"$TESTFILE1.*ftp://.*20010909_034640\"`" -eq 0
assert "$TESTFILE2 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20021216_015320" 
assert "$TESTFILE3 should appear with fullpath" $LINENO test "`files|grep $TESTFILE3`" == "$TESTFILE3 20021216_015321" 
assert "$TESTFILE4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE4`" == "$TESTFILE4 20021216_015322" 
assert "$TESTFILE5 should appear with fullpath" $LINENO test "`files|grep $TESTFILE5`" == "$TESTFILE5 20021216_015323" 

echo "Tests OK"
rm -rf $TMPDIR
