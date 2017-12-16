#!/bin/bash -xe
self_dir=`dirname "$(readlink -f $0)"`
source ${self_dir}/utils.sh

TMPDIR=`mktemp -d`
export PATH=$TMPDIR:$PATH
export DB=$TMPDIR/db.db
ln -sf ${self_dir}/test_curl $TMPDIR/curl

echo "Testing dir $TMPDIR"
echo "DB=$TMPDIR/db.db"

reset_db() {
  rm -f $DB
  sql "create table files (filename TEXT PRIMARY KEY NOT NULL, state INTEGER, mtime INTEGER)"
}

mock_curl() {
  $TMPDIR/curl "$@"
}

remove() {
    sql "UPDATE files SET state=1 WHERE filename='$1'"
}

findsort() {
    ${self_dir}/findsort.py $TMPDIR
}

upload() {

    DIR=$TMPDIR FTP=9.9.9.9 ${self_dir}/upload
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

test_file_name() {
  echo "$TMPDIR/test${1}.mp4"
}

test_file() {
    FN=`test_file_name $1`
    echo "Test" >$FN
    touch --date=@$2 $FN
    echo $FN
}

delete_test_files() {
  rm `test_file_name '*'`
}

mock_curl reset
reset_db
assert "Empty DB should be 0" $LINENO test `filecount` -eq 0
findsort
assert "Empty Directory should be 0" $LINENO test `filecount` -eq 0


touch $TMPDIR/zero.mp4
upload
assert "File with zero size should not appear" $LINENO test `filecount` -eq 0

TESTFILE1=`test_file 1 1000000000`
upload
assert "test1.mp4 should appear" $LINENO test `filecount` -eq 1
assert "test1.mp4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE1`" == "$TESTFILE1 20010909_034640" 


TESTFILE2=`test_file 2 1040000000`
TESTFILE3=`test_file 3 1040000001`
TESTFILE4=`test_file 4 1040000002`
TESTFILE5=`test_file 5 1040000003`

upload
assert "After upload it filecount should be 4" $LINENO test `filecount` -eq 4
assert "$TESTFILE1 should be uploaded" $LINENO test "`mock_curl dump|grep -c \"$TESTFILE1.*ftp://.*20010909_034640\"`" -eq 1
assert "$TESTFILE1 should appear with fullpath" $LINENO test "`all_files|grep $TESTFILE1`" == "$TESTFILE1 20010909_034640" 
assert "$TESTFILE1 should not be in uploadable state" $LINENO test "`files|grep -c $TESTFILE1`" -eq 0 
assert "$TESTFILE2 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20021216_015320" 
assert "$TESTFILE3 should appear with fullpath" $LINENO test "`files|grep $TESTFILE3`" == "$TESTFILE3 20021216_015321" 
assert "$TESTFILE4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE4`" == "$TESTFILE4 20021216_015322" 
assert "$TESTFILE5 should appear with fullpath" $LINENO test "`files|grep $TESTFILE5`" == "$TESTFILE5 20021216_015323" 

mock_curl reset
TESTFILE1=`test_file 1 1040000000`
upload

assert "$TESTFILE1 should be reuploaded with new filename" $LINENO test "`mock_curl dump|grep -c \"$TESTFILE1.*ftp://.*20021216_015320\"`" -eq 1
assert "$TESTFILE1 should be reuploaded with new filename, not with old" $LINENO test "`mock_curl dump|grep -c \"$TESTFILE1.*ftp://.*20010909_034640\"`" -eq 0
assert "$TESTFILE2 should appear with fullpath" $LINENO test "`files|grep $TESTFILE2`" == "$TESTFILE2 20021216_015320" 
assert "$TESTFILE3 should appear with fullpath" $LINENO test "`files|grep $TESTFILE3`" == "$TESTFILE3 20021216_015321" 
assert "$TESTFILE4 should appear with fullpath" $LINENO test "`files|grep $TESTFILE4`" == "$TESTFILE4 20021216_015322" 
assert "$TESTFILE5 should appear with fullpath" $LINENO test "`files|grep $TESTFILE5`" == "$TESTFILE5 20021216_015323" 

echo "Retrying? "
reset_db
mock_curl reset
mock_curl fail
delete_test_files
TESTFILE1=`test_file 1 1040000000`
for a in `seq 2 5`;do 
  test_file $a 104000000$a
done
upload

assert "After failed upload it filecount should be 5" $LINENO test `filecount` -eq 5
mock_curl reset
mock_curl fail 3
upload
assert "After upload it filecount should be 4" $LINENO test `filecount` -eq 4
assert "$TESTFILE1 should be uploaded" $LINENO test "`mock_curl dump|grep -c \"$TESTFILE1.*ftp://.*20021216_015320\"`" -eq 1

echo "Tests OK"
rm -rf $TMPDIR
