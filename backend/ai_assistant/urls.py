from django.urls import path
from . import views

urlpatterns = [
    path('ask/', views.ask_llm, name="ask_llm"),
]