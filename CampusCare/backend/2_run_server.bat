@echo off
cd /d "%~dp0"
call venv\Scripts\activate
echo Starting Campus Care backend. Keep this window open.
echo Open http://127.0.0.1:8000/admin/ in Chrome.
py manage.py runserver 0.0.0.0:8000
pause
