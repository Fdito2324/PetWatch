# 🐶 PetWatch – Instructivo de Instalación en Ambiente Productivo

Este instructivo guía paso a paso cómo instalar y ejecutar PetWatch en un entorno de desarrollo y producción, utilizando Flutter y Firebase.

## 📦 Requisitos Previos

Antes de instalar PetWatch, asegúrate de tener lo siguiente:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión estable recomendada)
- [Android Studio](https://developer.android.com/studio) o Visual Studio Code
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Cuenta en [Firebase Console](https://console.firebase.google.com/)
- Emulador o dispositivo físico (Android)
- Conexión a Internet

---

## ⚙️ Configuración del Proyecto

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/petwatch.git
cd petwatch
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Agregar archivo de configuración de Firebase

- **Android:**  
  Coloca tu archivo `google-services.json` dentro de:  
  `android/app/`

- **Web (opcional):**  
  El archivo `firebase_options.dart` ya está generado con FlutterFire CLI. Si necesitas regenerarlo:
  ```bash
  flutterfire configure
  ```

### 4. Habilitar servicios en Firebase Console

- Autenticación por Email/Contraseña
- Firestore Database
- Firebase Storage
- Firebase Cloud Messaging (para notificaciones push)
- Reglas seguras para Firestore y Storage

---

## ▶️ Ejecutar la Aplicación

### En Android

```bash
flutter run
```

### En Web (opcional)

```bash
flutter run -d chrome
```

> ℹ️ Nota: Para la versión web, asegúrate de configurar correctamente los CORS en Firebase Storage.

---

## 📱 Consideraciones Técnicas

- Las imágenes se almacenan en Firebase Storage y se vinculan en Firestore.
- La ubicación se obtiene con `geolocator`.
- Se utilizan permisos para ubicación, cámara/galería y notificaciones.
- Las notificaciones push funcionan mediante Firebase Cloud Messaging.

---

## 🧪 Pruebas recomendadas

- Registro e inicio de sesión de usuario
- Reportar un perro perdido con ubicación e imágenes
- Buscar reportes filtrados por color, raza y zona
- Comentar y chatear entre usuarios
- Ver estadísticas de uso en el dashboard

---

## 🛠️ Contacto de soporte

Para dudas técnicas o problemas de instalación, contacta al desarrollador:  
**fernandodiegovidal@hotmail.com**