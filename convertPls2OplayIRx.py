#!/usr/bin/python
import sys,re

pls=open(sys.argv[1])
dic={"^File[0-9]+=(.*)":"url","^Title[0-9]+=(.*)":"name"}
playlist=[]

def filled(d):
  for key,value in d.iteritems():
    if not key or not value:
      return False
  return True

i=0
item={"url":"","name":""}
for line in pls.readlines():
  for pattern,name in dic.iteritems():
    m=re.search(pattern,line)
    if m:
      item[name]=m.group(1)
    if filled(item):
      playlist.append(item)
      item={"url":"","name":""}
pls.close()
with open("IRxStationBitRate","w") as br:
  with open("IRxStationCodec","w") as codec:
    with open("IRxStationFavorite","w") as name:
      with open("IRxStationGenre","w") as gen:
        with open("IRxStationRegion","w") as reg:
          with open("IRxStationStream","w") as stream:
            with open("IRxStationUrl","w") as url:
              with open("IRxStationWebsite","w") as web:
                for item in playlist:
                  br.write("96\n")
                  codec.write("mp3\n")
                  name.write(item["name"]+"\n")
                  gen.write("\n")
                  reg.write("\n")
                  stream.write("\n")
                  url.write(item["url"]+"\n")
                  web.write("\n")
print "Put the result IRxStation* files to /usr/local/etc/dvdplayer on your O!Play..."


