"""Serializers turn model objects into JSON (and JSON back into objects)."""
from rest_framework import serializers

from .models import Report, User


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ["username", "password", "first_name", "student_id"]

    def create(self, validated_data):
        return User.objects.create_user(role=User.STUDENT, **validated_data)


class ReportSerializer(serializers.ModelSerializer):
    reporter_name = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = ["id", "title", "description", "category", "location", "status",
                  "admin_note", "reporter_name", "created_at", "updated_at"]
        read_only_fields = ["id", "reporter_name", "created_at", "updated_at"]

    def get_reporter_name(self, obj):
        return obj.reporter.first_name or obj.reporter.username
