from rest_framework import serializers

from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["uuid", "username", "email", "date_joined"]




class RegisterSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def validate_username_and_email(self, data):
        username = data.get('username')
        email = data.get('email')

        errors = {}

        # Check username uniqueness
        if User.objects.filter(username=username).exists():
            errors['username'] = "A user with this username already exists."

        # Check email uniqueness
        if User.objects.filter(email=email).exists():
            errors['email'] = "A user with this email address already exists."

        # If there are any errors, raise ValidationError
        if errors:
            raise serializers.ValidationError(errors)

        return data

    def validate(self, data):
        return self.validate_username_and_email(data)

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user