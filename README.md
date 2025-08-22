# 🛒 Mi Tienda

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28.svg)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#-licencia)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)]()

**Mi Tienda** es una aplicación móvil de **e-commerce** desarrollada con **Flutter** y **Firebase**.  
Permite a los usuarios explorar productos, ver descuentos, marcarlos como favoritos, añadirlos al carrito y gestionar su perfil.  
El objetivo es ofrecer una **experiencia de compra moderna y fluida**, inspirada en plataformas como Mercado Libre.

> **Autor:** Julián Rojas

---

## ✨ Características

- 🔐 **Autenticación de usuarios** con Firebase Authentication (registro e inicio de sesión).
- 📦 **Catálogo de productos dinámico** desde **Cloud Firestore** en tiempo real.
- ❤️ **Favoritos por usuario** (persistentes en Firestore).
- 🛒 **Carrito de compras** con cantidades, actualización y “checkout” simulado.
- 👤 **Perfil de usuario** con edición de nombre, dirección y método de pago.
- 💵 **Precios y descuentos** con formateo local (`intl`) y porcentaje de ahorro.
- ⚡ **UI responsiva** y **carga de imágenes cacheada** (`cached_network_image`).

---

## 🧱 Stack Tecnológico

- **Framework:** Flutter (Dart)
- **Backend/BBDD:** Firebase  
  - Authentication  
  - Cloud Firestore  
- **Gestión de estado:** `setState` (simple y directa en esta versión)
- **Paquetes clave:**
  - `firebase_core`, `cloud_firestore` — integración con Firebase
  - `firebase_auth` — autenticación
  - `cached_network_image` — imágenes optimizadas con cache
  - `intl` — formateo de moneda (ej. `es_CO`)

---

## 🖼️ Capturas


---

## 🖼️ Capturas

<table align="center">
  <tr>
    <td align="center"><img src="screens/login.jpg" alt="Login" width="200"/></td>
    <td align="center"><img src="screens/create.jpg" alt="Crear cuenta" width="200"/></td>
    <td align="center"><img src="screens/homepage.jpg" alt="Inicio / Catálogo" width="200"/></td>
    <td align="center"><img src="screens/description.jpg" alt="Detalle Producto" width="200"/></td>
  </tr>
  <tr>
    <td align="center"><img src="screens/favorites.jpg" alt="Favoritos" width="200"/></td>
    <td align="center"><img src="screens/shopping.jpg" alt="Carrito" width="200"/></td>
    <td align="center"><img src="screens/confirmation.jpg" alt="Confirmación" width="200"/></td>
    <td align="center"><img src="screens/profile.jpg" alt="Perfil / Checkout" width="200"/></td>
  </tr>
</table>

---

## 🚀 Cómo ejecutar el proyecto

### 1) Clonar e instalar dependencias
```bash
git clone https://github.com/julian1416/Tienda.git
cd Tienda
flutter pub get

---

## 🚀 Cómo ejecutar el proyecto

### 1) Clonar e instalar dependencias
```bash
git clone https://github.com/julian1416/Tienda.git
cd Tienda
flutter pub get
