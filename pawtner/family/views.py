from rest_framework import mixins, viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response

from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes, OpenApiExample

from django.contrib.auth import get_user_model

from pawtner.family.models import Family
from pawtner.family.serializers import FamilySerializer
from pawtner.pets.models import Pet

User = get_user_model()


class FamilyViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Family.objects.all()
    serializer_class = FamilySerializer
    lookup_field = 'uuid'
    permission_classes = [IsAuthenticated]

    async def perform_create(self, serializer):
        family = await serializer.asave(owner=self.request.user)
        await family.admins.aadd(self.request.user)
        await family.members.aadd(self.request.user)

    @action(detail=True, methods=['post'], url_path='add-member')
    async def add_member(self, request, uuid=None):
        family = await Family.objects.aget(uuid=uuid)

        is_admin = await family.admins.filter(pk=request.user.pk).aexists()
        if not is_admin:
            return Response(
                {'detail': 'Only the family admin can add members.'},
                status=status.HTTP_403_FORBIDDEN
            )

        user_uuid = request.data.get('user_uuid')
        if not user_uuid:
            return Response(
                {'detail': 'user_uuid is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user_to_add = await User.objects.aget(uuid=user_uuid)
        except User.DoesNotExist:
            return Response(
                {'detail': 'User does not exist.'},
                status=status.HTTP_404_NOT_FOUND
            )

        await family.members.aadd(user_to_add)

        return Response(
            {'detail': f'User {user_to_add.username} added to the family successfully.'},
            status=status.HTTP_200_OK
        )

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'pet_uuid': {'type': 'string', 'format': 'uuid'}
                },
                'required': ['pet_uuid'],
                'example': {'pet_uuid': 'abcd1234-5678-90ab-cdef-1234567890ab'}
            }
        },
        responses={200: {'description': 'Pet added successfully.'}},
    )
    @action(detail=True, methods=['post'], url_path='add-pet')
    async def add_pet(self, request, uuid=None):
        family = await Family.objects.aget(uuid=uuid)

        pet_uuid = request.data.get('pet_uuid')
        if not pet_uuid:
            return Response(
                {'detail': 'pet_uuid is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            pet_to_add = await Pet.objects.aget(uuid=pet_uuid)
        except Pet.DoesNotExist:
            return Response(
                {'detail': 'Pet does not exist.'},
                status=status.HTTP_404_NOT_FOUND
            )

        is_member = await family.members.filter(pk=request.user.pk).aexists()
        if pet_to_add.owner != request.user and not is_member:
            return Response(
                {'detail': 'You do not have permission to add this pet to the family.'},
                status=status.HTTP_403_FORBIDDEN
            )

        pet_to_add.family = family
        await pet_to_add.asave()

        return Response(
            {'detail': f'Pet "{pet_to_add.name}" added to the family successfully.'},
            status=status.HTTP_200_OK
        )

    @extend_schema(
        request={
            'application/json': {
                'type': 'object',
                'properties': {
                    'pet_uuid': {'type': 'string', 'format': 'uuid'}
                },
                'required': ['pet_uuid'],
                'example': {'pet_uuid': 'abcd1234-5678-90ab-cdef-1234567890ab'}
            }
        },
        responses={200: {'description': 'Pet removed successfully.'}},
    )
    @action(detail=True, methods=['post'], url_path='remove-pet')
    async def remove_pet(self, request, uuid=None):
        family = await Family.objects.aget(uuid=uuid)

        pet_uuid = request.data.get('pet_uuid')
        if not pet_uuid:
            return Response(
                {'detail': 'pet_uuid is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            pet_to_remove = await Pet.objects.aget(uuid=pet_uuid)
        except Pet.DoesNotExist:
            return Response(
                {'detail': 'Pet does not exist.'},
                status=status.HTTP_404_NOT_FOUND
            )

        is_admin = await family.admins.filter(pk=request.user.pk).aexists()
        if not is_admin:
            return Response(
                {'detail': 'You do not have permission to remove this pet from the family.'},
                status=status.HTTP_403_FORBIDDEN
            )

        if pet_to_remove.family != family:
            return Response(
                {'detail': 'This pet does not belong to this family.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        pet_to_remove.family = None
        await pet_to_remove.asave()

        return Response(
            {'detail': f'Pet "{pet_to_remove.name}" removed from the family successfully.'},
            status=status.HTTP_200_OK
        )

    @action(detail=True, methods=['post'], url_path='add-admin')
    async def add_admin(self, request, uuid=None):
        family = await Family.objects.aget(uuid=uuid)

        user_uuid = request.data.get('user_uuid')
        if not user_uuid:
            return Response(
                {'detail': 'user_uuid is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user_to_add = await User.objects.aget(uuid=user_uuid)
        except User.DoesNotExist:
            return Response(
                {'detail': 'User does not exist.'},
                status=status.HTTP_404_NOT_FOUND
            )

        is_admin = await family.admins.filter(pk=request.user.pk).aexists()
        if not is_admin:
            return Response(
                {'detail': 'You do not have permission to add user to the family admins.'},
                status=status.HTTP_403_FORBIDDEN
            )

        await family.admins.aadd(user_to_add)

        return Response(
            {'detail': f'User {user_to_add.username} added to the family admins successfully.'},
            status=status.HTTP_200_OK
        )