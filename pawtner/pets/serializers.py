from rest_framework import serializers
from pawtner.pets.models import Pet


# class PetSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Pet
#         fields = '__all__'
#         read_only_fields = ('owner',)


class PetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pet
        fields = ['uuid', 'owner', 'family', 'name', 'description', 'species', 'breed', 'created_at', 'updated_at']
        read_only_fields = ['uuid', 'owner', 'created_at', 'updated_at']