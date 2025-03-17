import uuid

from django.db import models
from django.contrib.auth import get_user_model

from pawtner.pets.species import PET_SPECIES, PET_BREED_CHOICES
from pawtner.profile.models import Family


User = get_user_model()

class Pet(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, primary_key=True)
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='pets', to_field='uuid')
    owner = models.ForeignKey(Family, on_delete=models.CASCADE, related_name='pets', to_field='uuid')
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True)
    species = models.CharField(choices=PET_SPECIES)
    breed = models.CharField(choices=PET_BREED_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.owner} - {self.name}"
