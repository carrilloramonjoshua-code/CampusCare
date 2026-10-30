from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import Group
from rest_framework.authtoken.models import TokenProxy

from .models import Report, User

admin.site.register(User, UserAdmin)
admin.site.register(Report)

# Hide the tables Campus Care doesn't need to show in the admin panel.
admin.site.unregister(Group)
admin.site.unregister(TokenProxy)
