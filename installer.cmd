@REM Copyright (c) 2025 anjisuan608
@echo off
title HONOR AI GameManager Install Tool
color 03

@REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 04
    echo 请以管理员身份运行此工具！
    pause
    goto x
)

@REM 创建临时文件夹
if not exist "%temp%\OpenVanilla" (
    mkdir "%temp%\OpenVanilla"
) else (
    goto c
)

:c
@REM 选择要执行的操作
echo =========================
echo 荣耀AI游戏管家安装工具
echo =========================
echo 键入 i 执行静默安装(Version 1.0.0.23)
echo 键入 s 执行服务检查
echo 键入 u 执行静默卸载
echo 键入 t 清理缓存目录
echo 键入 x 退出
echo =========================
choice /C isutx /CS
if errorlevel 5 goto x
if errorlevel 4 goto t
if errorlevel 3 goto u
if errorlevel 2 goto s
if errorlevel 1 goto i
echo 无效的输入，请重新选择。
goto c

:i
@REM 静默安装
if exist "%temp%\OpenVanilla\InstallPackage.zip" (
    echo goto UnZipPackage
) else (
    echo 开始下载
    powershell -Command "Invoke-WebRequest -Uri 'https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTUvDQBD9K7InhVJ2Z5LNpifTmoiHWqEVjzJptnExH2WSWKz4392UWOYwvMd78_F-xNBZ3n0frVgIEDNRtKdmgtrDg6vsM9UjfPRtTQ2Vlm_UXPoCvG3aqi3v3jPH9YnYzs_uOLleqP_wrjiMMFBhYHKNQQQRWTpIKNCGYPL8EHh17s5PhZduN_dvUsogNKg8vWdLvWubnRvXy5noXNlQP_B4TIYrAw8YyFiF2mTRMoogwThDjalewkrHGkySAoIBmSoDS4yVSVYZYpgqkH7-iXrLa-LPrKJSLJqhqmbCMre87q64pn1SFGy77p_5osoVr9fQeh7s5YUptO1G_P4B4Zr1f1UBAAA%3D.zip' -OutFile '%temp%\OpenVanilla\InstallPackage.zip'"
    echo 下载结束
)

:UnZipPackage
@REM 解压外部包
if exist "%temp%\OpenVanilla\InstallPackage.zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\InstallPackage.zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
    echo 解压完成
) else (
    echo 文件不存在，请检查网络连接。
    timeout /t 3
    echo.
    goto c
)
@REM 检查解压后的安装程序压缩包是否存在
if exist "%temp%\OpenVanilla\Software\GameManager_Setup_1.0.0.23.zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\Software\GameManager_Setup_1.0.0.23.zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
    echo 解压完成
) else (
    echo 文件不存在，请检查下载的文件是否正确。
    timeout /t 3
    goto t
    echo.
    goto c
)
@REM 静默安装
echo 开始安装
powershell -Command "Start-Process -FilePath '%temp%\OpenVanilla\GameManager_Setup_1.0.0.23.exe' -ArgumentList '/S' -Wait"
echo 安装结束
echo.
goto c

:s
@REM 服务存在性检查
echo 开始服务检查
powershell -Command "Get-Service -Name 'GameManagerService'"
if %errorlevel%==0 (
    echo 服务已安装
    goto ServiceStatus
) else (
    echo 服务未安装
   timeout /t 3
   echo.
   goto c
)

:ServiceStatus
@REM 检查服务启动状态检查
powershell -Command "Get-Service -Name 'GameManagerService' | Select-Object -Property Status"
if %errorlevel%==0 (
    echo 服务已启动
    goto c
) else (
    echo 服务未启动
    timeout /t 3
    echo.
    goto ServiceStart
)

:ServiceStart
@REM 启动服务
powershell -Command "Start-Service -Name 'GameManagerService'"
goto c

:u
@REM 卸载
@REM 检查是否安装
if exist "%programfiles%\GameManager\uninst.exe" (
    echo 卸载程序存在，开始卸载
    goto uninstall
) else (
    echo 卸载程序不存在，请检查安装路径。
    timeout /t 3
    echo.
    goto c
)

:uninstall
echo 正在尝试拉起卸载进程
powershell -Command "Start-Process -FilePath '%programfiles%\GameManager\uninst.exe' -ArgumentList '/S /uninstall' -Wait"
echo 卸载结束
echo.
goto c

:t
@REM 清理缓存目录
cls
echo 正在清理缓存目录
del /q "%temp%\OpenVanilla\*"
for /d %%i in ("%temp%\OpenVanilla\*") do rd /s /q "%%i"
echo 缓存已清理
echo.
goto c

:x
@REM 退出
timeout /t 3
exit