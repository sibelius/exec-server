# exec-server

curl "http://localhost:3000/exec?command=echo%20Hello%20World%20|%20pbcopy"

curl "http://localhost:3000/exec?command=open%20-a%20'Google%20Chrome'%20https://www.google.com"


## Mac Os X launchtl

Make exec-server run on launchd

Modify `com.woovi.execserver.plist` and `start-exec-server` to get the path from exec-server

```bash
launchctl load com.woovi.execserver.plist
```