# 🧪 API Testing Guide - Backend Integration

## ✅ Setup Lengkap - Siap Test

Backend API sudah terintegrasi dengan aplikasi Flutter. Mari test koneksinya!

---

## 🚀 Cara Test API

### Langkah 1: Pastikan Backend Berjalan
```bash
# Backend harus running di:
http://localhost:8000/api

# Verifikasi backend sudah berjalan dengan:
curl http://localhost:8000/api/health
# Should return 200 OK
```

### Langkah 2: Jalankan Flutter App
```bash
flutter run
```

### Langkah 3: Akses API Test Screen
1. App akan loading dengan splash screen
2. Di splash screen, ada tombol **"⚙️ API Test"** di kanan bawah
3. Klik tombol tersebut untuk masuk ke test screen

---

## 🧪 API Test Screen - Fitur

Test screen menyediakan tombol untuk test semua endpoint:

### 🟡 PUBLIC ENDPOINTS (Tidak perlu Token)

#### 1. **Health Check**
```
Endpoint: GET /health
Fungsi: Cek apakah backend sudah aktif
Response: { "message": "API is running" }
```

#### 2. **Register User**
```
Endpoint: POST /auth/register
Data:
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "phone": "08123456789"
}
Response: { "success": true, "message": "User registered" }
```

#### 3. **Login**
```
Endpoint: POST /auth/login
Data:
{
  "email": "test@test.com",
  "password": "password123"
}
Response: {
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJ..." 
  }
}
```

#### 4. **Forgot Password**
```
Endpoint: POST /auth/forgot-password
Data: { "email": "test@test.com" }
Response: { "success": true, "message": "Reset link sent" }
```

#### 5. **Get Products**
```
Endpoint: GET /products?page=1&per_page=10
Response: {
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Solar Panel 400W",
      "price": 2500000,
      ...
    }
  ]
}
```

### 🔴 PROTECTED ENDPOINTS (Perlu Token)

#### 6. **Get Current User**
```
Endpoint: GET /auth/me
Headers: Authorization: Bearer <token>
Response: {
  "success": true,
  "data": {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com",
    ...
  }
}
```

---

## 📋 Urutan Test yang Benar

**Untuk test protected endpoints, ikuti urutan ini:**

```
1. Health Check
   ↓ (verifikasi backend aktif)
   
2. Register User
   ↓ (membuat akun test)
   
3. Login
   ↓ (mendapatkan token)
   
4. Get Current User
   ↓ (test protected endpoint dengan token)
   
5. Get Products
   ↓ (test public endpoint)
```

---

## 📊 Response Format

Semua response dari backend mengikuti format:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    ...
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

### HTTP Status Codes
- **200**: OK - Request sukses
- **201**: Created - Resource dibuat
- **400**: Bad Request - Data tidak valid
- **401**: Unauthorized - Token invalid/expired
- **404**: Not Found - Resource tidak ditemukan
- **422**: Unprocessable Entity - Validasi gagal
- **500**: Internal Server Error - Error backend

---

## 🔧 Implementation Details

### Token Management
```dart
// Token otomatis disimpan setelah login di:
// FlutterSecureStorage (Android Keystore / iOS Keychain)

// Token otomatis ditambahkan ke header:
// Authorization: Bearer <token>

// Token otomatis dihapus jika:
// - User logout
// - Response 401 Unauthorized
```

### Error Handling
```dart
// Semua error ditangani dan diberikan pesan yang jelas:
- Koneksi timeout → "Koneksi timeout"
- Bad response → "Error 400", "Error 404", dll
- Network error → "Periksa koneksi internet"
```

### Request Logging
Semua request dan response di-log dengan format:
```
🌐 [GET] /health
📤 Data: null
✅ [200] /health
```

---

## 🐛 Troubleshooting

### "Connection refused" / "Unable to connect"
**Masalah**: Backend tidak berjalan
**Solusi**:
1. Pastikan backend berjalan di `http://localhost:8000`
2. Check firewall tidak memblokir port 8000
3. Test dengan: `curl http://localhost:8000/api/health`

### "401 Unauthorized" pada Protected Endpoints
**Masalah**: Token invalid atau expired
**Solusi**:
1. Login ulang untuk mendapatkan token baru
2. Token otomatis akan disimpan
3. Coba protected endpoint lagi

### "Timeout"
**Masalah**: Backend lambat atau tidak respond
**Solusi**:
1. Check backend logs
2. Verify backend memory/CPU
3. Restart backend service

### Email sudah terdaftar saat register
**Masalah**: Email sudah ada di database
**Solusi**:
1. Gunakan email baru dengan timestamp: `test{timestamp}@test.com`
2. Atau delete user dari database backend

---

## 📱 File-File Terkait

```
lib/
├── services/
│   └── api_client.dart           ← API client implementation
├── providers/
│   └── app_providers.dart        ← AuthProvider, ProductsProvider, dll
├── screens/
│   └── test/
│       └── api_test_screen.dart  ← Test screen UI
└── config/
    └── routes.dart               ← Routes config
```

---

## 🔄 API Client Methods

Semua method ada di `lib/services/api_client.dart`:

### Public Methods
```dart
healthCheck()
register(name, email, password, phone)
login(email, password)
forgotPassword(email)
resetPassword(email, token, password)
getProducts(page, perPage)
getProduct(id)
processMidtransWebhook(data)
```

### Protected Methods
```dart
logoutUser()
getCurrentUser()
getSolarCalculations(page, perPage)
getSolarCalculation(id)
createSolarCalculation(...)
updateSolarCalculation(id, ...)
deleteSolarCalculation(id)
getSolarCalculationFinancial(id)
getCart()
addToCart(productId, quantity)
updateCartItem(id, quantity)
removeCartItem(id)
clearCart()
getOrders(page, perPage)
getOrder(id)
checkout(data)
addProduct(...) // Admin only
```

---

## 📝 Next Steps Setelah Testing

Setelah API testing berhasil:

1. **Hapus Test Screen** (di production)
   - Test screen hanya untuk development
   
2. **Buat Authentication Flow**
   - LoginScreen
   - RegisterScreen
   - ForgotPasswordScreen
   
3. **Buat Product Screens**
   - ProductListScreen
   - ProductDetailScreen
   - CartScreen
   
4. **Buat Order Screens**
   - CheckoutScreen
   - OrdersHistoryScreen

5. **Integrate dengan UI**
   - Gunakan AuthProvider di LoginScreen
   - Gunakan ProductsProvider di ProductListScreen
   - dll

---

## ✅ Checklist

- [ ] Backend berjalan di `http://localhost:8000`
- [ ] Flutter app compiled dan running
- [ ] API Test Screen accessible via ⚙️ button di splash
- [ ] Health Check test sukses
- [ ] Register test sukses
- [ ] Login test sukses & mendapat token
- [ ] Get Current User test sukses (protected)
- [ ] Get Products test sukses
- [ ] Semua console logs terlihat di Android Studio

---

## 📞 Debug Console

Untuk melihat API logs, buka Android Studio:
1. Run → View → Debug Console
2. Atau: `flutter logs`

Logs akan menampilkan:
```
🌐 [POST] /auth/login
📤 Data: {email: test@test.com, password: password123}
✅ [200] /auth/login
```

---

## 🎯 Summary

Backend API sudah **fully integrated** dan siap ditest!

Gunakan API Test Screen untuk verifikasi semua endpoint bekerja sebelum lanjut ke implementasi screen utama.

**Happy Testing!** 🚀
