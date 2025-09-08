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
)

@REM 创建数据文件夹
if not exist "%AppData%\OpenVanilla\HnGMCfg" (
    mkdir "%AppData%\OpenVanilla\HnGMCfg"
) else (
    goto ve
)

:ve
@REM 定义版本号
set "version=1.0.0.30"
goto c

:c
@REM 选择要执行的操作
echo =========================
echo 荣耀AI游戏管家安装工具
echo =========================
echo 键入 i 安装游戏管家(%version%)
echo 键入 s 管理游戏管家服务
echo 键入 u 静默卸载游戏管家
echo 键入 t 清理缓存目录
echo 键入 e 编辑游戏管家支持游戏列表(xml文档)
echo 键入 m 安装其它版本(Legacy)
echo 键入 p 打开项目仓库
echo 键入 c 清屏
echo 键入 x 退出
echo =========================
choice /C isutvempcx /CS
if %errorlevel% == 1 goto i
if %errorlevel% == 2 goto s
if %errorlevel% == 3 goto u
if %errorlevel% == 4 goto t
if %errorlevel% == 5 goto v
if %errorlevel% == 6 goto e
if %errorlevel% == 7 goto m
if %errorlevel% == 8 goto p
if %errorlevel% == 9 goto CE
if %errorlevel% == 10 goto x
echo 无效的输入，请重新选择。
goto c

:i
@REM 静默安装
@REM set "version=" :: 已弃用,版本配置见顶部
set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTU-DQBD9K2ZPmpBmFxYWenIXivFQa9Iaj2aEATfy0QxgY43_3aXBZg6T9_LevJn5YdOAdPg-Ilszn3ms7E_dAiMHK9vgE7QzfHBtCx3USDdixV0F_Lbrm76-e8sttScgXJ3tcXE9w_jhXDwJRIgYQqVQQhEBhkIIX5QCRSxU5dTv9vxYOul-d__KOZeJTGJHF4Qw2r472Dmee2ywdQfjRPMySutNHEmtAt-oXEqTpcZomYW5H0eZVqEKXLIRUuk0y3iaSGNEGgc61cJs8szNP8GItAX6zBuo2bqbmsZjSNTTdrjiFgpdloTD8M98QWPLl-vTRprwcsLytP2O_f4BEfIjTVUBAAA%3D.zip"
:installShell
echo =========================
echo 当前目标版本 %version%
echo =========================

@REM 检查缓存目录是否为空
for /f %%i in ('dir "%temp%\OpenVanilla" /b') do (
    set "isEmpty=false"
    goto ClearDirectoryChoice
)
set "isEmpty=true"
goto SkipClear

:ClearDirectoryChoice
@REM 询问是否清空缓存目录
echo =========================
echo 缓存目录不为空，是否清空缓存目录?
echo 若不知道这是什么，请键入 y 清空缓存目录
echo 若选择了其它版本请键入 y 清空缓存目录
choice /C yn /CS /T 6 /D y /M "是否清空缓存目录? (键入 y 清空, 键入 n 不清空):"
if %errorlevel% == 2 goto SkipClear
if %errorlevel% == 1 goto ClearDirectory
goto ClearDirectoryChoice

:ClearDirectory
@REM 清空目录内容但保留缓存目录
if exist "%temp%\OpenVanilla" (
    del /q "%temp%\OpenVanilla\*"
    for /d %%i in ("%temp%\OpenVanilla\*") do rd /s /q "%%i"
)

:SkipClear

if exist "%temp%\OpenVanilla\InstallerPackage.zip" (
    echo goto UnZipPackage
) else (
    echo 开始下载
    powershell -Command "Invoke-WebRequest -Uri '%downloadUrl%' -OutFile '%temp%\OpenVanilla\InstallerPackage.zip'"
    echo 下载结束
)

:UnZipPackage
@REM 解压外部包
if exist "%temp%\OpenVanilla\InstallerPackage.zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\InstallerPackage.zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
    echo 解压完成
) else (
    echo 文件不存在，请检查网络连接。
    timeout /t 3
    echo.
    goto c
)
@REM 检查解压后的安装程序压缩包是否存在
if exist "%temp%\OpenVanilla\Software\GameManager_Setup_%version%.zip" (
    echo 文件存在，开始解压
    powershell -Command "Expand-Archive -Path '%temp%\OpenVanilla\Software\GameManager_Setup_%version%.zip' -DestinationPath '%temp%\OpenVanilla\' -Force"
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
powershell -Command "Start-Process -FilePath '%temp%\OpenVanilla\GameManager_Setup_%version%.exe' -ArgumentList '/S' -Wait"
echo 安装结束
copy "%xmlFile%" "%AppData%\OpenVanilla\FrameCollectConfig-%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.xml"
if exist "%AppData%\OpenVanilla\FrameCollectConfig-latest.xml" (
    type %xmlFile% > "%AppData%\OpenVanilla\FrameCollectConfig-latest.xml"
) else (
    copy %xmlFile% "%AppData%\OpenVanilla\FrameCollectConfig-latest.xml"
)
echo.
goto c

:s
@REM 管理服务
echo =========================
echo 键入 s 查询服务状态
echo 键入 r 重启服务
echo 键入 e 停止服务
echo 键入 b 启动服务
echo 键入 q 返回上一级菜单
echo =========================
choice /C srebq /CS
if %errorlevel% == 1 goto ServiceStatus
if %errorlevel% == 2 goto ServiceRestart
if %errorlevel% == 3 goto ServiceStop
if %errorlevel% == 4 goto ServiceStart
if %errorlevel% == 5 goto c
echo 无效的输入，请重新选择。
goto s

:ServiceStatus
@REM 查询服务状态
cls
echo 正在查询服务状态...
powershell -Command "Get-Service -Name 'GameManagerService'" >nul 2>&1
if %errorlevel% neq 0 (
    echo 未检测到 GameManagerService 服务。
    timeout /t 2
    goto s
)
powershell -Command "Get-Service -Name 'GameManagerService' | Select-Object -Property Status" | findstr /I "Running"
if %errorlevel% neq 0 (
    echo GameManagerService 服务未运行。
    goto ServiceStartChoice
) else (
    echo GameManagerService 服务正在运行。
)
goto s

:ServiceStartChoice
echo 服务未启动，是否现在启动服务?
choice /C yn /CS /M "请选择(键入 y 现在启动,键入 n 返回菜单): "
if %errorlevel% == 1 goto ServiceStart
if %errorlevel% == 2 goto s
echo 无效输入
goto ServiceStartChoice

:ServiceStart
@REM 启动服务
cls
powershell -Command "Get-Service -Name 'GameManagerService'" >nul 2>&1
if %errorlevel% neq 0 (
    echo 未检测到 GameManagerService 服务，无法启动。
    timeout /t 2
    goto s
)
echo 正在启动 GameManagerService 服务...
powershell -Command "Start-Service -Name 'GameManagerService'"
if %errorlevel%==0 (
    echo 服务已启动。
) else (
    echo 启动服务失败。
)
goto s

:ServiceStop
@REM 停止服务
cls
powershell -Command "Get-Service -Name 'GameManagerService'" >nul 2>&1
if %errorlevel% neq 0 (
    echo 未检测到 GameManagerService 服务，无法停止。
    timeout /t 2
    goto s
)
echo 正在停止 GameManagerService 服务...
powershell -Command "Stop-Service -Name 'GameManagerService'"
if %errorlevel%==0 (
    echo 服务已停止。
) else (
    echo 停止服务失败。
)
goto s

:ServiceRestart
@REM 重启服务
cls
powershell -Command "Get-Service -Name 'GameManagerService'" >nul 2>&1
if %errorlevel% neq 0 (
    echo 未检测到 GameManagerService 服务，无法重启。
    timeout /t 2
    goto s
)
echo 正在重启 GameManagerService 服务...
powershell -Command "Stop-Service -Name 'GameManagerService'"
if %errorlevel%==0 (
    echo 服务已停止。
    powershell -Command "Start-Service -Name 'GameManagerService'"
    if %errorlevel%==0 (
        echo 服务已启动。
    ) else (
        echo 启动服务失败。
    )
) else (
    echo 停止服务失败。
)
goto s

:u
@REM 卸载
@REM 检查是否安装
if exist "%programfiles%\GameManager\uninst.exe" (
    goto uninstallChoice
) else (
    cls
    echo 卸载程序不存在，请检查是否安装与安装路径。
    timeout /t 3
    echo.
    goto c
)

:uninstallChoice
echo 检测到卸载程序，是否确认卸载？
choice /C yn /CS /M "请选择(键入 y 确认卸载, 键入 n 取消并返回菜单): "
if %errorlevel% == 1 goto uninstall
if %errorlevel% == 2 goto c
echo 无效输入
goto uninstallChoice

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

:v
@REM 查询版本
@REM 获取软件版本信息
set "exeFile=%ProgramFiles%\GameManager\GameManager.exe"
if exist "%exeFile%" (
    for /f %%i in ('powershell -Command "Write-Output (Get-Item '%exeFile%').VersionInfo.ProductVersion"') do (
        echo 当前的版本为: %%i
    )
) else (
    echo 未检测到 GameManager.exe 请检查安装路径是否默认和是否已安装。
)
pause
goto c

:e
@REM 编辑游戏管家支持游戏列表(xml文档)
set "xmlFile=%ProgramFiles%\GameManager\FrameCollectConfig.xml"
if exist "%xmlFile%" (
    echo 检测到 FrameCollectConfig.xml
    goto EditXml
) else (
    cls
    echo 未检测到 FrameCollectConfig.xml 文件。
    echo.
    pause
)
goto c

:EditXml
@REM ====== 编辑游戏管家支持游戏列表模块 ======
echo =========================
echo 键入 b 管理配置文件 FrameCollectConfig.xml
echo 键入 s 使用系统默认方式打开
echo 键入 n 使用记事本打开
echo 键入 q 返回上一级菜单
echo =========================
choice /C bsnq /CS
if %errorlevel% == 4 goto c
if %errorlevel% == 3 (
    echo 正在用记事本打开 FrameCollectConfig.xml...
    start notepad "%xmlFile%"
    goto c
)
if %errorlevel% == 2 (
    echo 正在用系统默认方式打开 FrameCollectConfig.xml...
    start "" "%xmlFile%"
    goto c
)
if %errorlevel% == 1 goto BackupConfigManager
echo 无效的输入，请重新选择。
goto EditXml

:BackupConfigManager
@REM 备份配置文件管理
echo ========================
echo 键入 b 备份配置文件
echo 键入 r 还原配置文件
echo 键入 q 返回上一级菜单
echo ========================
choice /C brq /CS
if %errorlevel% == 3 goto e
if %errorlevel% == 2 goto RestoreConfigManagerChoice
if %errorlevel% == 1 goto BackupConfigManagerChoice
@REM 错误回收
echo 输入参数错误。
goto BackupConfigManager

:BackupConfigManagerChoice
@REM 备份配置文件选项
echo ========================
echo 键入 y 确认备份配置文件
echo 键入 n 返回上一级菜单
echo ========================
choice /C yn /CS
if %errorlevel% == 2 goto e
if %errorlevel% == 1 goto BackupConfigManagerShell
@REM 错误回收
echo 输入参数错误。
goto BackupConfigManagerChoice

:BackupConfigManagerShell
@REM 备份配置文件
echo 正在备份配置文件
copy "%xmlFile%" "%AppData%\OpenVanilla\HnGMCfg\FrameCollectConfig-%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%.xml"
if %errorlevel% neq 0 (
    echo 备份失败，请检查权限。
)
if exist "%AppData%\OpenVanilla\HnGMCfg\FrameCollectConfig-latest.xml" (
    type "%xmlFile%" > "%AppData%\OpenVanilla\HnGMCfg\FrameCollectConfig-latest.xml"
) else (
    copy "%xmlFile%" "%AppData%\OpenVanilla\HnGMCfg\FrameCollectConfig-latest.xml"
)
if %errorlevel% neq 0 (
    echo 备份失败，请检查权限。
)
echo 备份完成
echo.
goto BackupConfigManager

:RestoreConfigManagerChoice
@REM 还原配置文件选项
echo ========================
echo 键入 y 确认还原配置文件
echo 键入 n 返回上一级菜单
echo ========================
choice /C yn /CS
if %errorlevel% == 2 goto e
if %errorlevel% == 1 goto RestoreConfigLocationChoice
@REM 错误回收
echo 输入参数错误。
goto RestoreConfigManagerChoice

:RestoreConfigLocationChoice
@REM 还原配置文件位置选择
echo ========================
echo 键入 l 从最近的备份还原
echo 键入 o 从其它时间的备份还原
echo 键入 b 返回上一级菜单
echo ========================
choice /C lob /CS
if %errorlevel% == 3 goto e
if %errorlevel% == 2 goto RestoreConfigBackupHistory
if %errorlevel% == 1 set "restoreFile=%AppData%\OpenVanilla\HnGMCfg\FrameCollectConfig-latest.xml" && goto RestoreConfigManagerShell
@REM 错误回收
echo 输入参数错误。
goto RestoreConfigLocationChoice

:RestoreConfigBackupHistory
@REM 还原配置文件历史
echo ========================
echo 功能尚未实现
echo ========================
pause
goto RestoreConfigLocationChoice

:RestoreConfigManagerShell
@REM 还原配置文件
echo 正在还原配置文件
type %restoreFile% > "%xmlFile%"
if %errorlevel% neq 0 (
    echo 还原失败，请检查权限。
)
echo 还原完成
echo.
goto e

:m
@REM 安装其它版本
echo =========================
echo 降级安装建议先卸载原有版本!
echo 请选择要安装的版本——键入指定十六进制数字选择要安装的版本:
echo 旧版不再维护,链接可能失效!
echo 0 - 1.0.0.20(SP2)
echo 1 - 1.0.0.23
echo 2 - 1.0.0.26
echo 3 - 1.0.0.28
echo 4 - 1.0.0.30
echo =========================
@REM 操作说明: 添加对应下载选项后, 同时添加对应echo版本说明
choice /C 0123456789ABCDEF /CS /M "请选择(0~F):"
if %errorlevel% == 1 (
    set "version=1.0.0.20(SP2)"
    set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1Qy26DMBD8lcqnVkKRsc0rpxoIVQ80kUjVY7VgQ63yiBYoaqr-e52IRntYzWhmNTs_ZB41Hr9PmmwJIw5Rw9Kv0LewNq1-ge4Cn-zKoYdG4527oXYYvS8OrB_aoXl4zwx2C6DenM1pNR5g-rBGTgMoOXAOvhLAvNITCqrSdyGsRR2CVZfm_KystNg_vlFKhYhoYOkKNUxm6I_mkoA6ZDRND9OMlzycySANeRLtZJJ5IooSTuNQuDsp01hI5gcylJlIOPd8GoRpRH3GI5enKeNumsT2_gKTxhzwM2uhIdt-bluHaMQB8_GGO6ikUqjH8Z_5gtao11tvE876-sLaW7Env39rFHKXWAEAAA%3D%3D.zip"
    goto installShell
)
if %errorlevel% == 2 (
    set "version=1.0.0.23"
    set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTUvDQBD9K7InhVJ2Z5LNpifTmoiHWqEVjzJptnExH2WSWKz4392UWOYwvMd78_F-xNBZ3n0frVgIEDNRtKdmgtrDg6vsM9UjfPRtTQ2Vlm_UXPoCvG3aqi3v3jPH9YnYzs_uOLleqP_wrjiMMFBhYHKNQQQRWTpIKNCGYPL8EHh17s5PhZduN_dvUsogNKg8vWdLvWubnRvXy5noXNlQP_B4TIYrAw8YyFiF2mTRMoogwThDjalewkrHGkySAoIBmSoDS4yVSVYZYpgqkH7-iXrLa-LPrKJSLJqhqmbCMre87q64pn1SFGy77p_5osoVr9fQeh7s5YUptO1G_P4B4Zr1f1UBAAA%3D.zip"
    goto installShell
)
if %errorlevel% == 3 (
    set "version=1.0.0.26"
    set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTU-DQBD9K2ZPmpBmKAsLPVnYxXjAmrTGo5mWATfy0QxgY43_3cXUZg4vb_LefLxvMQ3Eu68jiZVYCk-U_am70MjRyjb0hO1MHxwU2GFNfOMvwNUyuu36pq_v3nLL7QmZFmd7vLiecXx3LkV7IAlYoQMpCZUPVQxRFSooD1Xs1Ht7fiyddLu5fwUAGcUQuvaBCUfbdzs7rwdPDLbucJx4PgZkoHS4BJX4xkjQaZiFUQ4mMrGUiTZ6DaAgTBMtU5OZdRDnmQoynWgfcpMbN_-EI3GB_JE3WItVNzWNJ4i552K48hYP67JkGob_zic2tny5hjbyRH8vXELbbsTPL4qz089VAQAA.zip"
    goto installShell
)
if %errorlevel% == 4 (
    set "version=1.0.0.28"
    set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTU-EMBD9K6YnTcim0NKWPQllMR5wTXaNRzMLBRv52AwgcY3_3WJwM4fJm7w3b-Z9k2kwePw6G7IlAfFI2c_dCoWDlW3ME7QLfHAthw5qgzf-hroK1G3XN31995ZZbGdAs7nY86p6hvHdqZisWEFpJGVouApBncJAgfCrKBSiAN-xT_byWDrqYX__SinlivPFukADo-27o13sqUcGW3cwTrgco4RMYx1IlfAok5LrJE6oZqlWUaCFzHjo83SnUxowR82EYGzHfCmoyJjUPHX7ZxgN5oAfWQM12XZT03jEIPaYD1fcQhGXJZph-J98QmPLl2toI07m74U1tMOe_PwCOwyzElUBAAA%3D.zip"
    goto installShell
)
if %errorlevel% == 5 (
    set "version=1.0.0.30"
    set "downloadUrl=https://iknow-dl.service.hihonor.com/ctkbfm/servlet/download/downloadServlet/H4sIAAAAAAAAAD1QTU-DQBD9K2ZPmpBmFxYWenIXivFQa9Iaj2aEATfy0QxgY43_3aXBZg6T9_LevJn5YdOAdPg-Ilszn3ms7E_dAiMHK9vgE7QzfHBtCx3USDdixV0F_Lbrm76-e8sttScgXJ3tcXE9w_jhXDwJRIgYQqVQQhEBhkIIX5QCRSxU5dTv9vxYOul-d__KOZeJTGJHF4Qw2r472Dmee2ywdQfjRPMySutNHEmtAt-oXEqTpcZomYW5H0eZVqEKXLIRUuk0y3iaSGNEGgc61cJs8szNP8GItAX6zBuo2bqbmsZjSNTTdrjiFgpdloTD8M98QWPLl-vTRprwcsLytP2O_f4BEfIjTVUBAAA%3D.zip"
    goto installShell
)
if %errorlevel% == 6 goto c
if %errorlevel% == 7 goto c
if %errorlevel% == 8 goto c
if %errorlevel% == 9 goto c
if %errorlevel% == 10 goto c
if %errorlevel% == 11 goto c
if %errorlevel% == 12 goto c
if %errorlevel% == 13 goto c
if %errorlevel% == 14 goto c
if %errorlevel% == 15 goto c
if %errorlevel% == 16 goto c
goto c

:p
@REM 打开项目仓库释放
cls
echo =========================
echo 请选择要打开哪个平台的项目仓库:
echo 若访问缓慢建议优先选择GitCode、Gitee、AtomGit(排名不分先后)
echo c - GitCode
echo e - Gitee
echo a - AtomGit
echo h - GitHub
echo q - 返回上一级菜单
echo =========================
choice /C ceahq /CS /M "请选择(c/e/a/h/q):"
if %errorlevel% == 1 (
    start https://gitcode.com/anjisuan608/HONOR-AI-GameManager-Install-Tool/releases
    goto c
)
if %errorlevel% == 2 (
    start https://gitee.com/anjisuan608/HONOR-AI-GameManager-Install-Tool/releases
    goto c
)
if %errorlevel% == 3 (
    start https://atomgit.com/anjisuan608/HONOR-AI-GameManager-Install-Tool/tags?tab=release
    goto c
)
if %errorlevel% == 4 (
    start https://github.com/anjisuan608/HONOR-AI-GameManager-Install-Tool/releases
    goto c
)
if %errorlevel% == 5 goto c
echo 无效的输入，请重新选择。
goto p

:CE
cls
goto c

:x
@REM 退出
color 02
timeout /t 3
exit