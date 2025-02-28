@echo off
cd flutter_answers_backend
start cmd /k "node server.js"
timeout /t 3 /nobreak >nul
cd ../flutter_answers_frontend
call flutter clean
call flutter pub get
start "" flutter run -d chrome --web-port=49792 --web-browser-flag="--disable-cache"