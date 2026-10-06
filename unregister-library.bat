@echo off
call "%~dp0hxgmod.bat" unregister %*
exit /b %errorlevel%
