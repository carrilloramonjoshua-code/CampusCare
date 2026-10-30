from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import LoginView, RegisterView, ReportViewSet

router = DefaultRouter()
router.register("reports", ReportViewSet, basename="report")

urlpatterns = [
    path("register/", RegisterView.as_view()),
    path("login/", LoginView.as_view()),
    path("", include(router.urls)),
]
