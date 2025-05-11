# 📦 PetWatch – Release Note v1.0.0

**Versión:** 1.0.0  
**Fecha de liberación:** 15 de abril de 2025  
**Responsable:** Fernando Vidal

## 🎯 Objetivo

Primera versión estable del aplicativo **PetWatch** para dispositivos Android, desarrollado con Flutter y Firebase.

## ✅ Funcionalidades incluidas

- Registro e inicio de sesión de usuarios (Email/Password)
- Recuperación de contraseñas
- Reporte de perros perdidos con fotos y ubicación
- Visualización de reportes en mapa interactivo (Google Maps)
- Búsqueda avanzada por raza, color, fecha y zona geográfica

## 📂 Archivos principales

- Código fuente: `/lib/`
- Configuración de Firebase: `firebase_options.dart`, `google-services.json`

## 🔒 Observaciones

- Aplicación validada en ambiente de pruebas (Android)
- Configuración CORS habilitada para imágenes en Web
--

# ⚙️ Gestión de la Configuración

## 🔁 Repositorio Git

Repositorio de control de versiones:  
`https://github.com/fernandovidal/petwatch`

Rama principal: `main`

## 🧰 Herramientas utilizadas

- **Git** para control de versiones
- **Flutter** como framework de desarrollo
- **Firebase** como backend en la nube

## 📌 Buenas prácticas aplicadas

- Commits semánticos (`feat:`, `fix:`, `refactor:`)
- Código estructurado por pantallas y servicios (`/lib/screens`, `/lib/services`)
- Modularización por componentes reutilizables
- Exclusión de archivos sensibles con `.gitignore`
- Gestión de dependencias mediante `pubspec.yaml`

---

**Fernando Vidal**