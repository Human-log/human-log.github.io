@echo off
cd /d "D:\matrix-blog"
powershell -ExecutionPolicy Bypass -File "generate-json.ps1"
"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "update"
"C:\Program Files\Git\bin\git.exe" push
echo Done!
pause
