@echo off
cd /d "%~dp0"
echo Creating virtual environment (can take a minute)...
py -m venv venv
call venv\Scripts\activate
echo Installing packages...
pip install -r requirements.txt
echo Building the database...
py manage.py migrate
echo.
echo Now create your ADMIN account. The password will not show as you type.
py manage.py createsuperuser
echo.
echo Setup done! Next, double-click 2_run_server.bat
pause
