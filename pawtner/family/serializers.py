from rest_framework import serializers
from pawtner.family.models import Family


class FamilySerializer(serializers.ModelSerializer):
    class Meta:
        model = Family
        fields = ['uuid', 'owner', 'members', 'name', 'description', 'created_at', 'updated_at']
        read_only_fields = ['uuid', 'owner', 'created_at', 'updated_at']