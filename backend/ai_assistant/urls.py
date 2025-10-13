from django.urls import path
from .views import ask_llm
from ai_assistant import views

urlpatterns = [
    path('ask/', views.ask_llm, name="ask_llm"),
]