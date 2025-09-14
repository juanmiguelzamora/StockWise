from django import forms
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from django.contrib.auth.models import Group  # <- needed to unregister
from .models import User

# -------------------------
# Custom forms for User
# -------------------------
class UserCreationForm(forms.ModelForm):
    password1 = forms.CharField(label="Password", widget=forms.PasswordInput)
    password2 = forms.CharField(label="Confirm Password", widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ("email", "is_staff", "is_superuser") 

    def clean_password2(self):
        if self.cleaned_data.get("password1") != self.cleaned_data.get("password2"):
            raise forms.ValidationError("Passwords do not match")
        return self.cleaned_data["password2"]

    def clean(self):   # ✅ correctly placed
        cleaned_data = super().clean()
        is_staff = cleaned_data.get("is_staff")
        is_superuser = cleaned_data.get("is_superuser")

        if not is_staff and not is_superuser:
            raise forms.ValidationError("User must be staff or superuser.")
        return cleaned_data

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user



class UserChangeForm(forms.ModelForm):
    password = ReadOnlyPasswordHashField()

    class Meta:
        model = User
        fields = ("email", "password", "is_superuser", "user_permissions")


# -------------------------
# Custom UserAdmin
# -------------------------
class CustomUserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = UserCreationForm

    list_display = ("email", "is_staff", "is_superuser",  "date_joined")
    list_filter = ("is_staff", "is_superuser", )
    search_fields = ("email",)
    ordering = ("email",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Permissions", {"fields": ("is_staff",  "is_superuser", "user_permissions")}),
        ("Important dates", {"fields": ("last_login", "date_joined")}),
    )

    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("email", "password1", "password2", "is_staff", "is_superuser", ),
        }),
    )

    filter_horizontal = ("user_permissions",)


# -------------------------
# Unregister defaults
# -------------------------
try:
    admin.site.unregister(User)
except admin.sites.NotRegistered:
    pass

# <-- THIS will remove Group from admin -->
try:
    admin.site.unregister(Group)
except admin.sites.NotRegistered:
    pass

# -------------------------
# Register only User
# -------------------------
admin.site.register(User, CustomUserAdmin)

# Change the header text (top left corner)
admin.site.site_header = "StockWise Admin Panel"

# Change the browser tab title
admin.site.site_title = "StockWise Admin"

# Change the index page title (main dashboard welcome text)
admin.site.index_title = "Welcome to StockWise Management"
