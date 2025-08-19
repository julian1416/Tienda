# 🛍️ Mi Tienda

**Mi Tienda** es una aplicación móvil de **e-commerce** desarrollada con **Flutter** y **Firebase**.  
Permite a los usuarios explorar productos, ver descuentos, marcarlos como favoritos y acceder a sus detalles de manera rápida y atractiva.  

Su objetivo es ofrecer una **experiencia de compra moderna y fluida**, similar a plataformas reconocidas como Mercado Libre.

---

## ✨ Características principales

- 🔐 **Autenticación de usuarios** con Firebase Authentication (registro e inicio de sesión).  
- 📦 **Catálogo de productos dinámico** cargado desde Firestore en tiempo real.  
- ❤️ **Sistema de favoritos** persistente por usuario.  
- 💵 **Gestión de precios y descuentos**, con cálculo automático de porcentaje de ahorro.  
- 🚚 **Envío gratis** en productos seleccionados.  
- ⚡ **UI optimizada**, rápida y responsiva, con imágenes cacheadas (`cached_network_image`).  

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter  
- **Backend y BDD:** Firebase (Firestore, Authentication, Storage)  
- **Gestión de estado:** (puedes especificar: Provider, setState, Riverpod, etc.)  
- **Paquetes clave:**  
  - `firebase_core` y `cloud_firestore` → integración con Firestore  
  - `firebase_auth` → autenticación de usuarios  
  - `cached_network_image` → carga optimizada de imágenes  
  - `intl` → formato de monedas  
  - *(agrega otros si los usaste, ej. provider, get_it, etc.)*

---

## 🚀 Cómo ejecutar el proyecto

1. Clona el repositorio:
   ```bash
   git clone https://github.com/julian1416/Tienda.git
