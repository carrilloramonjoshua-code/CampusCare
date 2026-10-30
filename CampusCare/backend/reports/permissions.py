from rest_framework.permissions import SAFE_METHODS, BasePermission


class StudentCreatesAdminUpdates(BasePermission):
    """Everyone logged in can read and create. Only admins can edit or delete."""

    def has_permission(self, request, view):
        if request.method in SAFE_METHODS or request.method == "POST":
            return request.user.is_authenticated
        return request.user.is_authenticated and request.user.is_admin_role
