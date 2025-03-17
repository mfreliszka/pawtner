
import uuid

from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import AbstractUser

from pawtner.pets.models import Pet

class PawtnerUser(AbstractUser):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, primary_key=True)
    profile_uuid = models.UUIDField(null=True, blank=True, editable=False, verbose_name="user_profile_uuid")
    # profile = models.ForeignKey("Profile", on_delete=models.DO_NOTHING, related_name='owner', to_field='uuid')
    families = models.ManyToManyField("Family")
    pets = models.ManyToManyField(Pet)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.username


class Profile(models.Model):
    uuid = models.UUIDField(default=uuid.uuid4, editable=False, unique=True, primary_key=True)
    owner = models.ForeignKey(PawtnerUser, on_delete=models.CASCADE, related_name='profile', to_field='uuid')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.owner} - profile"


@receiver(post_save, sender=PawtnerUser)
def create_root_folder(sender, instance, created, **kwargs):
    if created:
        profile = Profile.objects.create(owner=instance)
        PawtnerUser.objects.filter(pk=instance.pk).update(profile_uuid=profile.uuid)
