# HobbyMatch

App Flutter estilo Tinder para descubrir y conectar con eventos de hobbies cerca de ti: baloncesto, fútbol, running, gaming, juntas sociales y más.

## Características (MVP)

- **Swipe de eventos**: desliza a la derecha si te interesa, a la izquierda para pasar.
- **GPS real**: distancia calculada desde tu ubicación con `geolocator`.
- **Mapa de espacios**: 12 locales predefinidos en Viña del Mar y sectores cercanos usando OpenStreetMap.
- **Crear eventos**: elige espacio, categoría, fecha, descripción, etiquetas y cupos.
- **Validación de eventos**: título y descripción mínimos, fecha futura y cupos limitados por la capacidad del espacio.
- **Filtros por categoría** y **radio de búsqueda**.
- **Confirmación de asistencia mediante QR** en el prototipo local.

## Crear eventos

La pantalla de creación permite seleccionar un espacio de Viña del Mar, visualizarlo en el mapa y definir los datos del evento. Antes de publicarlo se valida que:

- El título tenga al menos 5 caracteres.
- La descripción tenga al menos 10 caracteres.
- La fecha y hora sean futuras.
- Los cupos no superen la capacidad del espacio seleccionado.
- Se puedan agregar hasta 8 etiquetas.

Actualmente los eventos se guardan en memoria mediante `EventsProvider`. Para permitir que otros usuarios los vean de forma persistente se debe conectar un backend, por ejemplo Firebase, Supabase o una API propia.

## Estructura relevante

```
lib/
├── data/
│   ├── mock_events.dart
│   └── predefined_venues.dart   # 12 espacios de Viña del Mar
├── models/
│   ├── geo_point.dart             # Centro por defecto de Viña del Mar
│   └── hobby_event.dart
├── providers/
│   ├── events_provider.dart
│   └── location_provider.dart
├── screens/
│   ├── map_screen.dart
│   └── create_event_screen.dart
└── widgets/
    ├── event_map_widget.dart
    └── venue_picker.dart
```
