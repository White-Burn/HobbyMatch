import '../models/event_category.dart';
import '../models/hobby_event.dart';

final mockEvents = <HobbyEvent>[
  HobbyEvent(
    id: '1',
    title: 'Partido 3x3 en la plaza',
    description:
        'Armamos equipos rotativos, nivel intermedio. Trae agua y buena onda. Cancha techada disponible.',
    category: EventCategory.basketball,
    dateTime: DateTime.now().add(const Duration(hours: 5)),
    venueId: 'plaza-nunoa',
    maxParticipants: 12,
    currentParticipants: 8,
    organizerName: 'Carlos M.',
    tags: ['3x3', 'Intermedio', 'Gratis'],
  ),
  HobbyEvent(
    id: '2',
    title: 'Fútbol 7 los sábados',
    description:
        'Partido amistoso todos los sábados. Buscamos arquero y un par de delanteros. Ambiente relajado.',
    category: EventCategory.football,
    dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
    venueId: 'estadio-providencia',
    maxParticipants: 14,
    currentParticipants: 11,
    organizerName: 'Equipo Los Leones',
    tags: ['Fútbol 7', 'Amateur', 'Semanal'],
  ),
  HobbyEvent(
    id: '3',
    title: 'After office: conoce gente nueva',
    description:
        'Juntada casual en un bar con juegos de mesa. Ideal si acabas de llegar a la ciudad o quieres ampliar tu círculo.',
    category: EventCategory.meetup,
    dateTime: DateTime.now().add(const Duration(days: 1, hours: 19)),
    venueId: 'bar-lastarria',
    maxParticipants: 20,
    currentParticipants: 14,
    organizerName: 'Ana R.',
    tags: ['Social', 'Networking', '25-35'],
  ),
  HobbyEvent(
    id: '4',
    title: 'Running grupal al amanecer',
    description:
        'Ruta de 8 km por el parque. Ritmo moderado, paradas para estirar. Todos los niveles bienvenidos.',
    category: EventCategory.running,
    dateTime: DateTime.now().add(const Duration(days: 1, hours: 6)),
    venueId: 'parque-bicentenario',
    maxParticipants: 25,
    currentParticipants: 18,
    organizerName: 'Runners CL',
    tags: ['8 km', 'Amanecer', 'Grupo'],
  ),
  HobbyEvent(
    id: '5',
    title: 'Torneo FIFA local',
    description:
        'Eliminatoria rápida 1v1 y luego equipos. Premio simbólico para el campeón. Trae tu mando si quieres.',
    category: EventCategory.gaming,
    dateTime: DateTime.now().add(const Duration(days: 3, hours: 16)),
    venueId: 'gamezone-las-condes',
    maxParticipants: 16,
    currentParticipants: 13,
    organizerName: 'Diego P.',
    tags: ['FIFA', 'Torneo', 'PS5'],
  ),
  HobbyEvent(
    id: '6',
    title: 'Yoga en el parque',
    description:
        'Sesión al aire libre para principiantes. Lleva tu mat. Instructor certificado, ambiente inclusivo.',
    category: EventCategory.yoga,
    dateTime: DateTime.now().add(const Duration(days: 2, hours: 8)),
    venueId: 'parque-forestal',
    maxParticipants: 30,
    currentParticipants: 22,
    organizerName: 'Valentina S.',
    tags: ['Principiantes', 'Al aire libre', 'Gratis'],
  ),
  HobbyEvent(
    id: '7',
    title: 'Jam session acústica',
    description:
        'Trae tu instrumento o solo ven a escuchar. Compartimos canciones y improvisamos juntos.',
    category: EventCategory.music,
    dateTime: DateTime.now().add(const Duration(days: 4, hours: 20)),
    venueId: 'casa-cultural-bellavista',
    maxParticipants: 15,
    currentParticipants: 6,
    organizerName: 'Marco L.',
    tags: ['Acústico', 'Abierto', 'Creativo'],
  ),
  HobbyEvent(
    id: '8',
    title: 'Noche de Catan y más',
    description:
        'Variedad de juegos de mesa modernos. Te enseñamos las reglas. Snacks incluidos, BYOB.',
    category: EventCategory.boardGames,
    dateTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
    venueId: 'cafe-ludico-nunoa',
    maxParticipants: 12,
    currentParticipants: 9,
    organizerName: 'BoardClub',
    tags: ['Catan', 'Estrategia', 'Casual'],
  ),
];
