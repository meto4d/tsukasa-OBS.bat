@echo off
setlocal
setlocal enabledelayedexpansion

::tsukasa入りffmpegの場所
set ffmpeg_path=ffmpeg.exe
::kagaminの場所(空欄で実行しない)
set kagamin_path=
::tsukasa待受rtmp
set rtmp=rtmp://127.0.0.1:1935/live/livestream
::置き場URL
set okiba=http://127.0.0.1:8000/
::借りるポート
set port=8080
::パスワード
set pass=1234
::コメント
::日本語入力はここから変換して、%を%%にしてください(例:%80e→%%80e)
:: https://www.benricho.org/moji_conv/16-URLencode_Shift_JIS.html
:: 例:フリーダムでお借りします
set comment=%%83t%%83%%8A%%81%%5B%%83_%%83%%80%%82%%C5%%82%%A8%%8E%%D8%%82%%E8%%82%%B5%%82%%DC%%82%%B7
::リザーブIP
set re_ip=
::配信URLの表示[on/off]
set showurl=off
::親リダイレクト[on/off]
set red_p=on
::子リダイレクト[on/off]
set red_c=on


::::::::::::::::::::::::
:: 以下処理部
::::::::::::::::::::::::

if not "%kagamin_path%" == "" (
    start %kagamin_path%
    timeout /t 5 /nobreak >nul
)

rem push接続
if "%okiba:~-1%" == "/" (
 set okiba=%okiba:~0,-1%
)
set tmp=!okiba!
set colonv=-1
for /l %%i in (0, 1, 7) do (
 if not %%i == 0 set tmp=!okiba:~0,-%%i!
 if "!tmp:~-1!" == "]" goto :END_V6
 if "!tmp:~-1!" == ":" (
  set colonv=%%i
  goto :FOR_END
 )
)
:END_V6
set okiba=%okiba%:
:FOR_END
if not %colonv% == -1 (
 set kagamin=!okiba:~0,-%colonv%!%port%
) else (
 set kagamin=!okiba!%port%
)
set url="%okiba%/conn.html?Port=%port%^&mode=push^&password=%pass%^&comment=%comment%^&radio=%showurl%^&redir_p=%red_p%^&redir_c=%red_c%^&reserve=%re_ip%^&url="

echo connect to %kagamin%
start "" "%url%"

timeout /t 1 /nobreak >nul 

:LOOP_ENCODE
%ffmpeg_path%　-v error -stats -itsoffset 300 -listen 1 -i %rtmp% -c copy -bsf:v h264_mp4toannexb -tag:v H264 -f asf_stream -map a -map v -push 1 -wms 1 %kagamin%
goto :LOOP_ENCODE

::pause
endlocal
