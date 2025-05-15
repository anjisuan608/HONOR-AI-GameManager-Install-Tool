@echo off
title HONOR AI GameManager Install Tool
color 03
mkdir "%temp%\OpenVanilla"
:c
@REM 选择要执行的操作
echo =========================
echo 荣耀AI游戏管家安装工具
echo =========================
echo 键入 i 执行静默安装
echo 键入 s 执行服务检查
echo 键入 x 退出
echo =========================
choice /C isx /CS
if errorlevel 3 goto x
if errorlevel 2 goto s
if errorlevel 1 goto i
echo 无效的输入，请重新选择。
goto c

:i
@REM 静默安装
if exist "%temp%\OpenVanilla\1_0_0_20_SP2.zip" (
    echo goto unzippackage
) else (
    echo 开始下载
    powershell -Command "Invoke-WebRequest -Uri 'https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTWuEMBT8KyWnFmSJSfzaU6OupQe7C27psTxNtKF-LE-tdEv_eyPY5R0eM8wMw_yQedR4_r5osieMOEQNS79B38LatPoFuhU-2ZdDD43GO3dH7TF6X5xYP7RD8_CeGewWQL27mstmPMH0YY2cBlBy4Bx8JYB5pScUVKXvQliLOgSrLs31WVlpcXx8o5QKEdHA0hVqmMzQn83agDpkNE0P04xrH85kkIY8iQ4yyTwRRQmncSjcg5RpLCTzAxnKTCScez4NwjSiPuORy9OUcTdNYpu_wKQxB_zMWmjIvp_b1iEaccB8vOEOKqkU6nH8Z2zbbaLiaFO-oDXq9TbjhLP-_QNxsjnbWAEAAA%3D%3D.zip' -OutFile '%temp%\OpenVanilla\1_0_0_20_SP2.zip'"
    echo 下载结束
)

:unzippackage
@REM 解压外部包
if exist "%temp%\OpenVanilla\1_0_0_20_SP2.zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\1_0_0_20_SP2.zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
    echo 解压完成
) else (
    echo 文件不存在，请检查网络连接。
    timeout /t 3
    echo.
    goto c
)
@REM 检查解压后的安装程序压缩包是否存在
if exist "%temp%\OpenVanilla\Software\GameManager_Setup_1.0.0.20(SP2).zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\Software\GameManager_Setup_1.0.0.20(SP2).zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
    echo 解压完成
) else (
    echo 文件不存在，请检查下载的文件是否正确。
    timeout /t 3
    echo.
    goto c
)
@REM 静默安装
echo 开始安装
powershell -Command "Start-Process -FilePath '%temp%\OpenVanilla\GameManager_Setup_1.0.0.20(SP2).exe' -ArgumentList '/S' -Wait"
echo 安装结束
echo.
goto c

:s
@REM 服务检查
echo 开始服务检查
powershell -Command "Get-Service -Name 'GameManagerService'"
if %errorlevel%==0 (
    echo 服务已安装
) else (
    echo 服务未安装
   timeout /t 3
   echo.
   goto c
)
goto c

:x
@REM 退出
timeout /t 3
exit