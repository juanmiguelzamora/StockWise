# File Tree: StockWises

Generated on: 10/3/2025, 7:24:35 PM
Root path: `c:\Users\ADMIN\Desktop\StockWises`

```
├── 📁 .git/ 🚫 (auto-hidden)
├── 📁 .venv/ 🚫 (auto-hidden)
├── 📁 apps/
│   ├── 📁 inventory/
│   │   ├── 📁 __pycache__/ 🚫 (auto-hidden)
│   │   ├── 📁 migrations/
│   │   │   ├── 📁 __pycache__/ 🚫 (auto-hidden)
│   │   │   ├── 🐍 0001_initial.py
│   │   │   ├── 🐍 0002_inventoryproduct_image.py
│   │   │   ├── 🐍 0003_stocktransaction.py
│   │   │   ├── 🐍 0004_stocktransaction_product_name_and_more.py
│   │   │   ├── 🐍 0005_remove_stocktransaction_product_name_and_more.py
│   │   │   └── 🐍 __init__.py
│   │   ├── 📁 tests/
│   │   │   └── 🐍 __init__.py
│   │   ├── 🐍 __init__.py
│   │   ├── 🐍 admin.py
│   │   ├── 🐍 apps.py
│   │   ├── 🐍 models.py
│   │   ├── 🐍 serializer.py
│   │   ├── 🐍 signals.py
│   │   ├── 🐍 tests.py
│   │   ├── 🐍 urls.py
│   │   └── 🐍 views.py
│   └── 📁 users/
│       ├── 📁 __pycache__/ 🚫 (auto-hidden)
│       ├── 📁 migrations/
│       │   ├── 📁 __pycache__/ 🚫 (auto-hidden)
│       │   ├── 🐍 0001_initial.py
│       │   └── 🐍 __init__.py
│       ├── 📁 templates/
│       │   └── 🌐 login_page.html
│       ├── 📁 tests/
│       ├── 🐍 __init__.py
│       ├── 🐍 admin.py
│       ├── 🐍 apps.py
│       ├── 🐍 auth_urls.py
│       ├── 🐍 authentication.py
│       ├── 🐍 firebase_config.py
│       ├── 🐍 models.py
│       ├── 🐍 password_reset_urls.py
│       ├── 🐍 permissions.py
│       ├── 🐍 serializers.py
│       ├── 🐍 signals.py
│       ├── 🐍 tests.py
│       ├── 🐍 urls.py
│       └── 🐍 views.py
├── 📁 core/
│   ├── 📁 __pycache__/ 🚫 (auto-hidden)
│   ├── 🐍 __init__.py
│   ├── 🐍 asgi.py
│   ├── 📄 db.sqlite3
│   ├── 🐍 settings.py
│   ├── 🐍 urls.py
│   └── 🐍 wsgi.py
├── 📁 frontend/
│   ├── 📁 .vscode/ 🚫 (auto-hidden)
│   ├── 📁 dist/ 🚫 (auto-hidden)
│   ├── 📁 node_modules/ 🚫 (auto-hidden)
│   ├── 📁 public/
│   │   ├── 📁 media/
│   │   │   └── 🖼️ Headphone.png
│   │   ├── 📄 items.json
│   │   ├── 🖼️ loginlogo.png
│   │   ├── 🖼️ toplogo.png
│   │   └── 🖼️ vite.svg
│   ├── 📁 src/
│   │   ├── 📁 assets/
│   │   │   ├── 🖼️ Ellipse 11.png
│   │   │   ├── 🖼️ Exit.png
│   │   │   ├── 🖼️ StockwiseLogo.svg
│   │   │   ├── 🖼️ arrow.png
│   │   │   ├── 🖼️ bluetooth_speaker.png
│   │   │   ├── 🖼️ headphone.png
│   │   │   ├── 🖼️ icon1.png
│   │   │   ├── 🖼️ icon2.png
│   │   │   ├── 🖼️ icon3.png
│   │   │   ├── 🖼️ icondelete.png
│   │   │   ├── 🖼️ iconedit.png
│   │   │   ├── 🖼️ iconsearch.png
│   │   │   ├── 🖼️ loginlogo.png
│   │   │   ├── 🖼️ mainlogo.png
│   │   │   ├── 🖼️ mouse.png
│   │   │   ├── 🖼️ nani.jpg
│   │   │   ├── 🖼️ react.svg
│   │   │   ├── 🖼️ resetlogo.png
│   │   │   ├── 🖼️ signuplogo.png
│   │   │   ├── 🖼️ toplogo.png
│   │   │   └── 🖼️ vite.svg
│   │   ├── 📁 components/
│   │   │   ├── 📁 forms/
│   │   │   ├── 📁 layout/
│   │   │   └── 📁 ui/
│   │   │       ├── 📄 button.tsx
│   │   │       ├── 📄 card.tsx
│   │   │       ├── 📄 deletepopup.tsx
│   │   │       ├── 📄 input.tsx
│   │   │       ├── 📄 loadingspinner.tsx
│   │   │       ├── 📄 modals.tsx
│   │   │       ├── 📄 rolepopup.tsx
│   │   │       └── 📄 searchbar.tsx
│   │   ├── 📁 contexts/
│   │   │   └── 📄 ThemeContext.tsx
│   │   ├── 📁 hooks/
│   │   │   └── 📄 useScrollDirection.ts
│   │   ├── 📁 layout/
│   │   │   └── 📄 navbar.tsx
│   │   ├── 📁 pages/
│   │   │   ├── 📄 AiAssistant.tsx
│   │   │   ├── 📄 Dashboard.tsx
│   │   │   ├── 📄 Inventory.tsx
│   │   │   ├── 📄 Login.tsx
│   │   │   ├── 📄 Profile.tsx
│   │   │   ├── 📄 ResetConfirm.tsx
│   │   │   ├── 📄 ResetPassword.tsx
│   │   │   ├── 📄 ResetRequest.tsx
│   │   │   ├── 📄 Signup.tsx
│   │   │   ├── 📄 cropImage.ts
│   │   │   └── 📄 user.tsx
│   │   ├── 📁 services/
│   │   │   ├── 📄 api.ts
│   │   │   ├── 📄 authservice.ts
│   │   │   └── 📝 file_tree.md
│   │   ├── 🎨 App.css
│   │   ├── 📄 App.tsx
│   │   ├── 📄 declaration.d.ts
│   │   ├── 🎨 index.css
│   │   ├── 📄 main.tsx
│   │   └── 🎨 reset.css
│   ├── 🚫 .gitignore
│   ├── 📖 README.md
│   ├── 📝 TAILWIND_SETUP.md
│   ├── 📄 eslint.config.js
│   ├── 🌐 index.html
│   ├── 📄 package-lock.json
│   ├── 📄 package.json
│   ├── 📄 postcss.config.js
│   ├── 📄 tailwind.config.js
│   ├── 📄 tsconfig.json
│   └── 📄 vite.config.js
├── 📁 media/
│   ├── 📁 products/
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_1qcoYHC.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_MwHQkV4.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_Vl4D3GI.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_WewlZah.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_hXudw23.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_qgWP1Zt.jpg
│   │   ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73_zqKCoZp.jpg
│   │   ├── 🖼️ 1_d3f9f165-7ff4-4308-b339-b99831e77e8d_1.png
│   │   ├── 🖼️ 1_d3f9f165-7ff4-4308-b339-b99831e77e8d_1_dpn1Dc0.png
│   │   ├── 🖼️ 1_d3f9f165-7ff4-4308-b339-b99831e77e8d_1_iqirZ4B.png
│   │   ├── 🖼️ 1z2ofw.jpg
│   │   ├── 🖼️ 1z2ofw_FDVuhpF.jpg
│   │   ├── 🖼️ Computer_login-pana_1.png
│   │   ├── 🖼️ Headphone.png
│   │   ├── 🖼️ Headphone_47YJbUx.png
│   │   ├── 🖼️ Headphone_4qdYKOn.png
│   │   ├── 🖼️ Headphone_9IRXvMT.png
│   │   ├── 🖼️ Headphone_A1dyrOj.png
│   │   ├── 🖼️ Headphone_CK0eDCw.png
│   │   ├── 🖼️ Headphone_DINJZRI.png
│   │   ├── 🖼️ Headphone_Dmlr10h.png
│   │   ├── 🖼️ Headphone_I4rfDof.png
│   │   ├── 🖼️ Headphone_RDEAdTN.png
│   │   ├── 🖼️ Headphone_TYB90X0.png
│   │   ├── 🖼️ Headphone_TgTZaXZ.png
│   │   ├── 🖼️ Headphone_UTsWGfG.png
│   │   ├── 🖼️ Headphone_XLH2oBA.png
│   │   ├── 🖼️ Headphone_XiYxBEq.png
│   │   ├── 🖼️ Headphone_YknuT3A.png
│   │   ├── 🖼️ Headphone_jFJ8Ll3.png
│   │   ├── 🖼️ Headphone_p363B1l.png
│   │   ├── 🖼️ Headphone_s2HfuuB.png
│   │   ├── 🖼️ Headphone_wOPuZ7v.png
│   │   ├── 🖼️ Headphone_yT6qZ4Y.png
│   │   ├── 🖼️ Headphone_yfptnTa.png
│   │   ├── 📄 images.jfif
│   │   ├── 📄 images_2tP4AO8.jfif
│   │   ├── 📄 images_At4Dgyi.jfif
│   │   ├── 📄 images_JynCjE1.jfif
│   │   ├── 📄 images_Kst5KsV.jfif
│   │   ├── 📄 images_ccmWubg.jfif
│   │   ├── 🖼️ img2.png.jpg
│   │   ├── 🖼️ img2_6nEf9Lx.png.jpg
│   │   ├── 🖼️ img2_A4jX0lP.png.jpg
│   │   ├── 🖼️ img2_PoILgWT.png.jpg
│   │   ├── 🖼️ img2_c1igC8v.png.jpg
│   │   ├── 🖼️ img2_cxHnUhY.png.jpg
│   │   ├── 🖼️ img2_hRcbXIg.png.jpg
│   │   └── 🖼️ logitech-g502-x-plus-wireless-rgb-gaming-mouse-_1.png
│   └── 📁 profile_pics/
│       ├── 🖼️ 18e3ad7a432d41a6e2a57d1523e81c73.jpg
│       ├── 🖼️ IMG_20250925_141252.jpg
│       ├── 🖼️ IMG_20250925_141252_MBxUMfy.jpg
│       ├── 🖼️ Screenshot_2025-09-10-13-56-16-904_com.ss.android.ugc.trill.jpg
│       ├── 🖼️ Screenshot_2025-09-10-13-56-16-904_com_6GStxJc.ss.android.ugc.trill.jpg
│       ├── 🖼️ Screenshot_2025-09-23-20-06-55-016_com.ss.android.ugc.trill.jpg
│       ├── 🖼️ Screenshot_2025-09-23-20-06-55-016_com_CXfstBL.ss.android.ugc.trill.jpg
│       ├── 🖼️ Screenshot_2025-09-23-20-06-55-016_com_bqxcseU.ss.android.ugc.trill.jpg
│       ├── 🖼️ Screenshot_2025-09-23-20-06-55-016_com_moXihi7.ss.android.ugc.trill.jpg
│       ├── 📄 images.jfif
│       ├── 🖼️ img2.png.jpg
│       ├── 🖼️ img2_AS1Vr0d.png.jpg
│       ├── 🖼️ img2_ZR4xCBG.png.jpg
│       ├── 🖼️ img2_gPpwslv.png.jpg
│       ├── 🖼️ img2_rJllQgK.png.jpg
│       ├── 🖼️ profile.jpg
│       ├── 🖼️ profile_01FyzTL.jpg
│       ├── 🖼️ profile_D9VIBYL.jpg
│       ├── 🖼️ profile_FQIdj2v.jpg
│       ├── 🖼️ profile_OvNwIKZ.jpg
│       ├── 🖼️ profile_Z9O7t6n.jpg
│       ├── 🖼️ profile_icAfNI5.jpg
│       ├── 🖼️ profile_jetz3eX.jpg
│       └── 🖼️ profile_kUFJvXE.jpg
├── 🔒 .env 🚫 (auto-hidden)
├── 🚫 .gitignore
├── 📖 README.md
├── 📄 db.sqlite3
├── 🐍 manage.py
└── 📄 requirements.txt
```

---
*Generated by FileTree Pro Extension*