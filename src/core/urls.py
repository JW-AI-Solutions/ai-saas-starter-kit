from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('api/inference/', views.inference_demo, name='inference_demo'),
]