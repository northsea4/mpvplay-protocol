@echo off
Setlocal EnableDelayedExpansion

:: 该脚本暂不可用！
:: TODO 先支持原链接格式
:: TODO 支持 weblink 格式

echo 输入参数: %1
set input=%~1
set url=%input%

:: 处理 weblink 格式
echo 检查是否是 weblink 格式...
set "isweblink="
cmd /c exit /b 0
echo %input%|findstr /i "mpvplay://weblink?url=" >nul && set isweblink=1
if defined isweblink (
    echo 是 weblink 格式
    :: 提取 url 参数
    set url=!input:mpvplay://weblink?url==%!
    echo 提取的URL: !url!
    :: URL解码
    call :urldecode url
    echo URL解码后: !url!
)

:: 去掉 mpvplay:// 前缀
echo 原始URL: !url!
set url=!url:mpvplay://=!
echo 去掉前缀后: !url!

:: 修复 Chrome 130+ 格式
echo 检查是否需要修复 Chrome 130+ 格式...
set "needfix="
cmd /c exit /b 0
echo !url!|findstr /i "^http//" >nul && set needfix=1
if defined needfix (
    echo 修复 Chrome 130+ 格式
    set url=!url:http//=http://!
    echo 修复后: !url!
)

:: 确保空格被编码
echo 处理空格编码...
set url=!url: =%%20!
echo 最终URL: !url!

:: 检查 MPV 是否存在
if not exist "%~dp0mpv.exe" (
    echo 错误: 找不到 mpvplay.exe
    echo 当前目录: %~dp0
    echo 请确保此脚本在 MPV 安装目录中。
    pause
    exit /b 1
)

:: 启动 MPV
echo 正在启动 MPV...
echo 命令行: "%~dp0mpv.exe" --open "!url!"
start "" "%~dp0mpv.exe" --open "!url!"

:: 显示完成信息并暂停
echo.
echo 处理完成。如果 MPV 没有启动，请检查上面的输出信息。
pause
exit /b

:urldecode
:: 保存原始值
set input=!%1!
set output=

:decode_loop
:: 检查是否还有字符需要处理
if "!input!"=="" goto decode_end

:: 获取第一个字符
set char=!input:~0,1!
set input=!input:~1!

:: 处理百分号编码
if "!char!"=="%" (
    :: 获取两个十六进制字符
    set hex=!input:~0,2!
    set input=!input:~2!
    
    :: 处理常见的编码
    if /i "!hex!"=="20" set char= 
    if /i "!hex!"=="2F" set char=/
    if /i "!hex!"=="3A" set char=:
    if /i "!hex!"=="3F" set char=?
    if /i "!hex!"=="3D" set char==
    if /i "!hex!"=="26" set char=^&
)

:: 处理加号
if "!char!"=="+" set char= 

:: 添加到输出
set output=!output!!char!
goto decode_loop

:decode_end
:: 设置结果
set %1=!output!
goto :eof
