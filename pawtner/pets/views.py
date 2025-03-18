from rest_framework import mixins, viewsets
from rest_framework.permissions import IsAuthenticated
from pawtner.pets.models import Pet
from pawtner.pets.serializers import PetSerializer


class PetViewSet(
        mixins.CreateModelMixin,
        mixins.RetrieveModelMixin,
        viewsets.GenericViewSet,
):
    queryset = Pet.objects.all()
    serializer_class = PetSerializer
    lookup_field = 'uuid'
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
