from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path


def home(request):
    """Friendly page for http://127.0.0.1:8000/ so it isn't a 404."""
    return JsonResponse({"app": "Campus Care API", "status": "running",
                         "admin_panel": "/admin/", "api": "/api/"})


urlpatterns = [
    path("", home),
    path("admin/", admin.site.urls),
    path("api/", include("reports.urls")),
]
