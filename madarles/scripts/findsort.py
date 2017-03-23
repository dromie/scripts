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
  c.execute("SELECT 1 FROM files WHERE filename=:file",{'file':file})
  if c.fetchone() is None:
    stat=os.stat(file)
    c.execute("INSERT INTO files (filename,state,mtime) VALUES (:file,0,:mtime)",{'file':file,'mtime':int(stat.st_mtime)})
db.commit()

