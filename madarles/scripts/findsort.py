#!/usr/bin/python3
import os,sys,errno,sqlite3,subprocess
suffix="mp4"

def get_db():
    DB=os.environ.get("DB")
    return sqlite3.connect(DB)

filelist=subprocess.check_output(['find',sys.argv[1],'-type','f','-size','+0','-name','*.'+suffix]).decode().split('\n')
filelist.remove('')
db = get_db()
c = db.cursor()
for file in filelist:
    stat=os.stat(file)
    file_record = {'file':file,'mtime': int(stat.st_mtime)}
    c.execute("SELECT mtime FROM files WHERE filename=:file",{'file':file})
    row = c.fetchone()
    if row is None:
        c.execute("INSERT INTO files (filename,state,mtime) VALUES (:file,0,:mtime)",file_record)
    else:
        if row[0] < file_record['mtime']:
            c.execute("UPDATE files SET state=0,mtime=:mtime WHERE filename=:file",file_record)
    db.commit()

