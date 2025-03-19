import uuid

from django.contrib.auth import get_user_model
from django.db import models


User = get_user_model()

class Family(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, primary_key=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_families')
    admins = models.ManyToManyField(User, related_name="admin_of_families")
    members = models.ManyToManyField(User, related_name="member_of_families")
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.owner}'s {self.name} family"
