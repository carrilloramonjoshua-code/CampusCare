"""The API endpoints. Each class is one 'door' the Flutter app can knock on."""
from django.contrib.auth import authenticate
from rest_framework import viewsets
from rest_framework.authtoken.models import Token
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Report
from .permissions import StudentCreatesAdminUpdates
from .serializers import RegisterSerializer, ReportSerializer


def session_payload(user):
    token, _ = Token.objects.get_or_create(user=user)
    return {"token": token.key, "role": user.role, "name": user.first_name or user.username}


class RegisterView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(session_payload(user), status=201)


class LoginView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = authenticate(username=request.data.get("username"),
                            password=request.data.get("password"))
        if user is None:
            return Response({"detail": "Wrong username or password."}, status=400)
        return Response(session_payload(user))


class ReportViewSet(viewsets.ModelViewSet):
    """list / create / retrieve / update / delete reports.
    Students only ever see their own reports; admins see all of them."""

    serializer_class = ReportSerializer
    permission_classes = [StudentCreatesAdminUpdates]

    def get_queryset(self):
        qs = Report.objects.select_related("reporter")
        user = self.request.user
        return qs if user.is_admin_role else qs.filter(reporter=user)

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)

    @action(detail=False, methods=["get"])
    def stats(self, request):
        qs = self.get_queryset()
        return Response({
            "total": qs.count(),
            "pending": qs.filter(status=Report.PENDING).count(),
            "in_progress": qs.filter(status=Report.IN_PROGRESS).count(),
            "resolved": qs.filter(status=Report.RESOLVED).count(),
        })
