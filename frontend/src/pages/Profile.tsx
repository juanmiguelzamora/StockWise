// src/pages/Profile.tsx
import { useEffect, useState, ChangeEvent } from "react";
import Navbar from "../layout/navbar";
import api from "../services/api";
import Cropper from "react-easy-crop";
import getCroppedImg from "./cropImage";

// ---- Types ----
interface User {
  email: string;
  profile_picture?: string | null;
  is_superuser?: boolean;
  is_staff?: boolean;
}

interface PasswordData {
  old_password: string;
  new_password: string;
  confirm_password: string;
}

interface CroppedArea {
  x: number;
  y: number;
  width: number;
  height: number;
}

export default function Profile() {
  const [saving, setSaving] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  const [showEdit, setShowEdit] = useState<boolean>(false);
  const [showPassword, setShowPassword] = useState<boolean>(false);

  const [formData, setFormData] = useState<{ email: string }>({ email: "" });
  const [profilePicture, setProfilePicture] = useState<Blob | null>(null);
  const [preview, setPreview] = useState<string | null>(null);

  const [crop, setCrop] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [zoom, setZoom] = useState<number>(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<CroppedArea | null>(
    null
  );
  const [croppingImage, setCroppingImage] = useState<string | null>(null);

  const [passwordData, setPasswordData] = useState<PasswordData>({
    old_password: "",
    new_password: "",
    confirm_password: "",
  });

  useEffect(() => {
    fetchUser();
  }, []);

  useEffect(() => {
  return () => {
    if (preview) URL.revokeObjectURL(preview);
  };
}, [preview]);

  const fetchUser = async (): Promise<void> => {
    try {
      const res = await api.get<User>("users/me/");
      setUser(res.data);
      setFormData({ email: res.data.email });
      setPreview(res.data.profile_picture || null);
    } catch (err: any) {
      alert(err.response?.data?.detail || "Failed to load profile");
    } finally {
      setLoading(false);
    }
  };

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>): void => {
    const file = e.target.files?.[0];
    if (file) {
      const imageUrl = URL.createObjectURL(file);
      setCroppingImage(imageUrl); // show in cropper modal
    }
  };

 const updateProfile = async (): Promise<void> => {
  try {
    setSaving(true); // start loading
    const form = new FormData();
    form.append("email", formData.email);
    if (profilePicture) {
      form.append("profile_picture", profilePicture, "profile.jpg");
    }
    await api.patch("users/me/", form, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    fetchUser();
    setShowEdit(false);
    if (profilePicture) setProfilePicture(null);
  } catch (err: any) {
    alert(err.response?.data?.detail || "❌ Failed to update profile");
  } finally {
    setSaving(false); // stop loading
  }
};

  const changePassword = async (): Promise<void> => {
  if (passwordData.new_password !== passwordData.confirm_password) {
    alert("New password and confirmation do not match");
    return;
  }

  // ✅ Password strength check
  if (passwordData.new_password.length < 8) {
    alert("Password must be at least 8 characters");
    return;
  }

  try {
    await api.post("users/change-password/", passwordData);
    alert("✅ Password updated successfully");
    setShowPassword(false);
    setPasswordData({
      old_password: "",
      new_password: "",
      confirm_password: "",
    });
  } catch (err: any) {
    alert(err.response?.data?.detail || "Failed to change password");
  }
};

  if (loading) return <p className="p-6">Loading profile...</p>;

  return (
    <>
      <Navbar />
      <section className="mt-32 px-6 md:px-16 lg:px-24">
        {/* Profile Header */}
<div className="bg-gray-100 rounded-2xl shadow p-6 flex items-center gap-4">
  <div className="w-20 aspect-square rounded-full border border-gray-300 flex items-center justify-center overflow-hidden">
    {user?.profile_picture ? (
      <img
        src={
          user.profile_picture?.startsWith("http")
            ? user.profile_picture
            : `${import.meta.env.VITE_API_URL}${user.profile_picture}`
        }
        alt="Profile"
        className="w-full h-full object-cover"
      />
    ) : (
      <i className="fa-regular fa-user text-gray-500 text-3xl" />
    )}
  </div>
      <div>
            <h2 className="text-xl font-semibold text-gray-800">
              {user?.email}
            </h2>
            <p className="text-gray-500">
              {user?.is_superuser
                ? "Admin"
                : user?.is_staff
                ? "Staff"
                : "User"}
            </p>
          </div>
        </div>

        {/* Personal Information */}
        <div className="mt-6 bg-gray-100 rounded-2xl shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-800">
              Personal Information
            </h3>
            <div className="flex gap-3">
              <button
                onClick={() => setShowEdit(true)}
                className="px-4 py-2 rounded-lg bg-black text-white text-sm hover:opacity-90"
              >
                Edit
              </button>
              <button
                onClick={() => setShowPassword(true)}
                className="px-4 py-2 rounded-lg bg-gray-400 text-white text-sm hover:opacity-90"
              >
                Change password
              </button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-gray-700">
            <div>
              <p className="text-sm text-gray-500">Email</p>
              <p className="font-medium">{user?.email}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500">User Role</p>
              <p className="font-medium">
                {user?.is_superuser
                  ? "Admin"
                  : user?.is_staff
                  ? "Staff"
                  : "User"}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Edit Popup */}
      {showEdit && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-40">
          <div className="bg-white rounded-xl p-6 w-96 shadow">
            <h2 className="text-lg font-semibold mb-4">Edit Profile</h2>

            {/* Email */}
            <label className="block mb-3">
              <span className="text-sm text-gray-500">Email</span>
              <input
                type="email"
                value={formData.email}
                onChange={(e) =>
                  setFormData({ ...formData, email: e.target.value })
                }
                className="mt-1 block w-full border rounded-lg px-3 py-2"
              />
            </label>

            {/* Profile Picture */}
            <label className="block mb-3">
              <span className="text-sm text-gray-500">Profile Picture</span>
              <input
                type="file"
                accept="image/*"
                onChange={handleFileChange}
                className="mt-1 block w-full text-sm text-gray-500"
              />
            </label>

            {preview && (
              <img
                src={preview}
                alt="Preview"
                className="w-20 h-20 rounded-full mt-2 object-cover border"
              />
            )}

            {/* Cropping Modal */}
            {croppingImage && (
              <div className="fixed inset-0 flex flex-col items-center justify-center bg-black bg-opacity-40 p-4">
                <div className="relative w-full max-w-md h-96 bg-gray-200 rounded-lg">
                  <Cropper
                    image={croppingImage}
                    crop={crop}
                    zoom={zoom}
                    aspect={1}
                    onCropChange={setCrop}
                    onZoomChange={setZoom}
                    onCropComplete={(_, croppedPixels) =>
                      setCroppedAreaPixels(croppedPixels as CroppedArea)
                    }
                  />
                </div>
                <div className="mt-4 flex gap-2">
                  <button
                    onClick={async () => {
                      if (croppingImage && croppedAreaPixels) {
                        const croppedBlob: Blob = await getCroppedImg(
                          croppingImage,
                          croppedAreaPixels
                        );
                        setProfilePicture(croppedBlob);
                        setPreview(URL.createObjectURL(croppedBlob));
                        setCroppingImage(null);
                      }
                    }}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg"
                  >
                    Crop & Use
                  </button>
                  <button
                    onClick={() => setCroppingImage(null)}
                    className="px-4 py-2 bg-gray-300 rounded-lg"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}

            <div className="flex justify-end gap-3 mt-4">
              <button
                onClick={() => setShowEdit(false)}
                className="px-4 py-2 bg-gray-300 rounded-lg"
              >
                Cancel
              </button>
             <button
  onClick={updateProfile}
  disabled={saving}
  className="px-4 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
>
  {saving ? "Saving..." : "Save"}
</button>
            </div>
          </div>
        </div>
      )}

      {/* Change Password Popup */}
      {showPassword && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-40">
          <div className="bg-white rounded-xl p-6 w-96 shadow">
            <h2 className="text-lg font-semibold mb-4">Change Password</h2>
            <label className="block mb-3">
              <span className="text-sm text-gray-500">Old Password</span>
              <input
                type="password"
                value={passwordData.old_password}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    old_password: e.target.value,
                  })
                }
                className="mt-1 block w-full border rounded-lg px-3 py-2"
              />
            </label>
            <label className="block mb-3">
              <span className="text-sm text-gray-500">New Password</span>
              <input
                type="password"
                value={passwordData.new_password}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    new_password: e.target.value,
                  })
                }
                className="mt-1 block w-full border rounded-lg px-3 py-2"
              />
            </label>
            <label className="block mb-3">
              <span className="text-sm text-gray-500">Confirm Password</span>
              <input
                type="password"
                value={passwordData.confirm_password}
                onChange={(e) =>
                  setPasswordData({
                    ...passwordData,
                    confirm_password: e.target.value,
                  })
                }
                className="mt-1 block w-full border rounded-lg px-3 py-2"
              />
            </label>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setShowPassword(false)}
                className="px-4 py-2 bg-gray-300 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={changePassword}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
