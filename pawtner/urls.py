from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView


urlpatterns = [
    ## DOCS
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    # user app
    path("user/", include('pawtner.user.urls')),
    # pets app
    path("pets/", include('pawtner.pets.urls')),
    # family app
    path("family/", include('pawtner.family.urls')),
]