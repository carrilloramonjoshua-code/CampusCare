# Campus Care
Student problem reporting & tracking.
- backend/  = Django + Django REST Framework + SQLite
- frontend/ = Flutter (student + admin screens)

## Run the backend
cd backend
python -m venv venv
venv\Scripts\activate          (Windows)   |   source venv/bin/activate (Mac/Linux)
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser      <- this account is your ADMIN
python manage.py runserver 0.0.0.0:8000

## Run the frontend
cd frontend
flutter create .               <- generates android/ios/web folders (keeps my lib/ and pubspec)
flutter pub get
flutter run -d chrome          (or pick an emulator)
