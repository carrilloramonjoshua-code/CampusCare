"""The database tables of Campus Care, written as classes (OOP)."""
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """Base account for everyone who logs in. It inherits username, password
    (hashed, never stored as plain text) and name from Django's AbstractUser,
    and adds only what Campus Care needs: a role and a student ID."""

    STUDENT = "student"
    ADMIN = "admin"
    ROLE_CHOICES = [(STUDENT, "Student"), (ADMIN, "Admin")]

    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=STUDENT)
    student_id = models.CharField(max_length=20, blank=True)

    @property
    def is_admin_role(self):
        return self.role == self.ADMIN

    def save(self, *args, **kwargs):
        """A superuser made with createsuperuser is automatically an admin."""
        if self.is_superuser:
            self.role = self.ADMIN
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.username} ({self.role})"


class Report(models.Model):
    """One problem reported by a student. Status moves:
    pending -> in_progress -> resolved (only admins change it)."""

    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    STATUS_CHOICES = [
        (PENDING, "Pending"),
        (IN_PROGRESS, "In progress"),
        (RESOLVED, "Resolved"),
    ]
    CATEGORY_CHOICES = [
        ("facilities", "Facilities"),
        ("safety", "Safety"),
        ("cleanliness", "Cleanliness"),
        ("academic", "Academic"),
        ("other", "Other"),
    ]

    reporter = models.ForeignKey(User, on_delete=models.CASCADE, related_name="reports")
    title = models.CharField(max_length=120)
    description = models.TextField()
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default="other")
    location = models.CharField(max_length=120, blank=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default=PENDING)
    admin_note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"#{self.pk} {self.title} [{self.status}]"
