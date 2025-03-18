# Generated by Django 5.1.7 on 2025-03-18 21:55

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('family', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name='family',
            name='members',
            field=models.ManyToManyField(related_name='member_of_families', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='family',
            name='owner',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='owned_families', to=settings.AUTH_USER_MODEL),
        ),
    ]
