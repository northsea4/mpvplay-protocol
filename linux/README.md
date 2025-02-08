```shell
sudo cp mpvplay-protocol /usr/local/bin/
xdg-desktop-menu install mpvplay-protocol.desktop
xdg-open mpvplay://https://pbs.twimg.com/tweet_video/Cx5L_3FWgAAxzpM.mp4
```

To install using curl:
```shell
sudo curl -L -o /usr/local/bin/mpvplay-protocol https://github.com/stefansundin/mpvplay-protocol/raw/main/linux/mpvplay-protocol
sudo chmod +x /usr/local/bin/mpvplay-protocol
curl -L -o mpvplay-protocol.desktop https://github.com/stefansundin/mpvplay-protocol/raw/main/linux/mpvplay-protocol.desktop
xdg-desktop-menu install mpvplay-protocol.desktop
rm mpvplay-protocol.desktop
```

Uninstall:
```shell
xdg-desktop-menu uninstall mpvplay-protocol.desktop
sudo rm /usr/local/bin/mpvplay-protocol
```
