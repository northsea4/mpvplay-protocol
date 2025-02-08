# MPV Protocol Handler

这是一个跨平台的 MPV 协议处理程序，支持通过点击 `mpvplay://` 链接来用 MPV 播放视频。

## 功能特性

- 支持多种 URL 格式：
  - 标准格式：`mpvplay://http://example.com/video.mp4`
  - Chrome 130+ 格式（自动修复）：`mpvplay://http//example.com/video.mp4`
  - weblink 格式：`mpvplay://weblink?url=http%3A%2F%2Fexample.com%2Fvideo.mp4`
- 跨平台支持：
  - Windows：支持 PowerShell、批处理和可执行文件三种安装方式
  - macOS：支持命令行和图形界面安装

## 平台支持

### Windows
- 支持 Windows 10 及以上版本
- 提供三种安装方式：
  1. PowerShell 脚本: 推荐
  2. 批处理脚本：简单直接，暂不支持 weblink 格式
  3. 可执行文件：性能最佳
- 详细说明请查看 [windows/README.md](windows/README.md)

### macOS
- 支持 macOS 10.15 及以上版本
- 安装方式：下载压缩包后，解压app目录到`/Applications`下即可
- 详细说明请查看 [macos/README.md](macos/README.md)

## 浏览器配置

### Firefox
1. 打开 `about:config`
2. 搜索 `network.protocol-handler.expose.mpvplay`
3. 创建为布尔值并设置为 `false`

### Chrome
- Chrome 130 以前：直接点击链接即可使用
- Chrome 130 及以后：自动修复新的 URL 格式

### Safari
- macOS：直接点击链接即可使用
- 其他平台：不支持

## 相关项目

- [mpv-handler](https://github.com/akiirui/mpv-handler) - A protocol handler for mpv. Use mpv and yt-dlp to play video and music from the websites.

## 安全说明

- 仅支持 http:// 和 https:// 链接
- 不支持执行任意命令

## 贡献

欢迎提交 Pull Request 或 Issue！

## 许可证

GPLv3
