rem version 1.2
ECHO OFF
rem %1 website_name %2 website_dir
if not exist %systemroot%\system32\inetsrv\appcmd.exe (
echo appcmd file not exist
rem delete had copy to server's file
rd /s /q %2\%1
exit
)
%systemroot%\system32\inetsrv\appcmd.exe list site "%1"
if "%errorlevel%"=="0" (
echo site %1 exist
exit
)

rem add apppool
cd %systemroot%\system32\inetsrv
appcmd list apppool "%1"
if "%errorlevel%" NEQ "0" (
    appcmd add apppool /name:%1 /managedRuntimeVersion:v4.0 /queueLength:10000 /processModel.maxProcesses:1
)

rem add site
appcmd add site /name:%1 /bindings:"http://%1:80" /physicalPath:"%2\%1"
if "%errorlevel%" NEQ "0" (
echo create site %1 failed
exit
)

rem set site
appcmd set app %1/ /applicationPool:%1
if "%errorlevel%" NEQ "0" (
echo set appool %1 failed
exit
)

echo add site %1 successfull
exit