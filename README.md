# HobbyMatch

App Flutter estilo Tinder para descubrir y conectar con **eventos de hobbies** cerca de ti: baloncesto, fútbol, running, gaming, juntas sociales y más.

## Características (MVP)

- **Swipe de eventos**: desliza a la derecha si te interesa, a la izquierda para pasar
- **GPS real**: distancia calculada desde tu ubicación con `geolocator`
- **Mapa de espacios**: 12 locales predefinidos en Santiago (OpenStreetMap)
- **Crear eventos**: elige espacio, categoría, fecha y cupos
- **Filtros por categoría** y **radio de búsqueda** (2–25 km)
- **Mis eventos**, detalle con mapa, perfil con control de GPS

## Requisitos

- Flutter 3.x (probado con 3.24.4)
- Dart 3.5+

## Cómo ejecutar

**Importante (Windows):** Si falla con *"Espacio en disco insuficiente"*, tu disco **C:** probablemente está casi lleno. Flutter compila en la carpeta temporal de Windows (`C:\Users\...\AppData\Local\Temp`).

### Opción rápida (recomendada)

Doble clic en `run.bat` o en PowerShell:

```powershell
cd "D:\Vicente\Escritorio\HobbyMatch"
.\run.ps1
```

Ese script usa `D:\Temp` como carpeta temporal y lanza la app en Edge.

### Opción manual

```bash
cd HobbyMatch
flutter pub get
flutter run -d edge
```

Para web o un dispositivo concreto:

```bash
flutter run -d edge
flutter run -d windows
```

### Si aún no arranca

1. **Libera espacio en C:** — deja al menos **5–10 GB** libres (Flutter y Windows lo necesitan).
2. **Modo desarrollador** — Configuración → Privacidad y seguridad → Para desarrolladores → activar *Modo de desarrollador* (necesario para plugins con symlinks).
3. **App Windows nativa** — instala [Visual Studio](https://visualstudio.microsoft.com/downloads/) con la carga *Desarrollo de escritorio con C++*.
4. **Android** — conecta un teléfono o emulador y ejecuta `flutter doctor --android-licenses`.

## Estructura del proyecto

```
lib/
├── main.dart
├── data/
│   ├── mock_events.dart
│   └── predefined_venues.dart   # 12 espacios con coordenadas GPS
├── models/
├── providers/
│   ├── events_provider.dart
│   └── location_provider.dart   # GPS del usuario
├── services/location_service.dart
├── screens/
│   ├── map_screen.dart          # Mapa + espacios
│   └── create_event_screen.dart # Crear evento
├── widgets/
│   ├── event_map_widget.dart
│   └── venue_picker.dart
└── ...
```

## Próximos pasos sugeridos

1. **Backend real** (Firebase, Supabase o API propia) para eventos y usuarios
2. **Geolocalización** con `geolocator` para filtrar por distancia real
3. **Autenticación** (Google, Apple, email)
4. **Chat** entre participantes de un evento
5. **Crear eventos** desde la app
6. **Notificaciones push** para recordatorios y nuevos eventos

## Stack

- Flutter + Material 3
- `provider` — gestión de estado
- `flutter_card_swiper` — cards deslizables
- `google_fonts` — tipografía
- `intl` — fechas en español
