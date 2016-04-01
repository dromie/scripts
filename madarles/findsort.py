#!/usr/bin/python
import os,sys,errno
suffix="mp4"

filelist = []
for (dirpath, dirnames, filenames) in os.walk(sys.argv[1]):
  filelist.extend(map(lambda ff:dirpath+'/'+ff,filenames))
filelist = filter(lambda x:x.lower().endswith(suffix),filelist)


filelist = map(lambda x:(x,os.stat(x)),filelist)

filelist = filter(lambda x:x[1].st_size>0,filelist)

sort = sorted(filelist,key=lambda x:x[1].st_mtime)

try:
  for f in map(lambda x:x[0],sort):
    print f
except IOError as e:
  if e.errno == errno.EPIPE:
    pass
  else:
    raise e





