In the case more than 1000 files appear in this directory, you can get the URLs of all of them through this command line:

```console
curl -s "https://api.github.com/repos/Windows81/Personal-Roblox-Client-Scripts/contents/logs?ref=main"|grep -Po "(?<=html_url...).+"
```
