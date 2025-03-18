from rest_framework import mixins, viewsets, permissions, generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from django.db.models.signals import post_save
from django.dispatch import receiver

from pawtner.user.serializers import (
    UserSerializer,
    RegisterSerializer,
)

User = get_user_model()


class UserViewSet(mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "uuid"

    def retrieve(self, request, uuid=None):
        if uuid == "default":
            user = request.user
        else:
            user = get_object_or_404(User, uuid=uuid)
        serializer = self.get_serializer(user)
        return Response(serializer.data)



class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        """
        Overriding CreateAPIView to customize response after creating a user.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        # generate a token for the new user for auto-login upon registration.
        refresh = RefreshToken.for_user(user)
        data = {
            "uuid": user.uuid,
            "username": user.username,
            "email": user.email
        }
        return Response(data, status=status.HTTP_201_CREATED)