# taskflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Alcance de TaskFlow

Un estudiante que prepara un proyecto de Flutter necesita reunir en un solo lugar las actividades de configuración, modelado, interfaz, navegación y revisión, para saber qué ha completado y qué requiere atención.

El usuario objetivo es un estudiante que organiza el trabajo semanal de su proyecto. En la sesión 5 puede consultar cinco tareas locales y abrir sus detalles. La creación, edición y eliminación se implementarán en sesiones posteriores.

### Historias de usuario y criterios de aceptación

1. Como estudiante, quiero listar mis tareas para decidir en qué trabajar primero. **Criterio de aceptación.** La lista muestra cinco tarjetas con título, prioridad e icono de estado.
2. Como estudiante, quiero consultar una tarea para leer sus instrucciones. **Criterio de aceptación.** Al tocar una tarjeta, su detalle muestra el identificador, título, descripción, prioridad, estado y usuario de esa tarea.
3. Como estudiante, quiero crear una tarea para registrar una actividad nueva. **Criterio de aceptación.** Al guardar un formulario con título, descripción y prioridad válidos, la nueva tarea aparece como pendiente en la lista.
4. Como estudiante, quiero editar una tarea para actualizar sus datos si cambian las instrucciones. **Criterio de aceptación.** Tras guardar un cambio de título, el nuevo título aparece en la lista y en el detalle de la misma tarea.
5. Como estudiante, quiero eliminar una tarea terminada para despejar la lista. **Criterio de aceptación.** Después de confirmar la eliminación, la tarjeta de esa tarea desaparece.

### Pantallas previstas

| Pantalla | Contenido y acciones |
| --- | --- |
| Lista | Tarjetas con título, prioridad y estado. Desde cada tarjeta se abre el detalle. En una sesión posterior se añadirá la acción para crear una tarea. |
| Detalle | Identificador, título, descripción, prioridad, estado y usuario de la tarea elegida. Las acciones de editar y eliminar quedan previstas. |
| Formulario | Pantalla futura con campos de título, descripción y prioridad para crear o editar una tarea. |

### Requisitos no funcionales

- La navegación y los mensajes usan textos comprensibles en español.
- Si el identificador del detalle es inválido o la tarea no existe, la pantalla muestra «No se encontró esta tarea» y la aplicación sigue funcionando.

### Modelo de datos y contrato JSON

| Campo de `Task` | Tipo Dart | Significado |
| --- | --- | --- |
| `id` | `int` | Identificador único de la tarea. |
| `title` | `String` | Título que identifica la tarea en la lista. |
| `description` | `String` | Instrucciones o información de la tarea. |
| `priority` | `String` | `Alta`, `Media` o `Baja`. |
| `isCompleted` | `bool` | `true` para completada y `false` para pendiente. |
| `userId` | `int` | Identificador del propietario. Las tareas locales pertenecen al usuario de prueba `1`. |

`Task.fromJson` espera estas seis claves con sus tipos correspondientes. Este ejemplo representa una tarea completada del listado local.

```json
{
  "id": 1,
  "title": "Configurar estructura del proyecto",
  "description": "Inicializar el repositorio Git local, conectar con la rama remota en GitHub y verificar el entorno de Flutter.",
  "priority": "Alta",
  "isCompleted": true,
  "userId": 1
}
```

### Contrato de API previsto

| Método y ruta | Operación |
| --- | --- |
| `GET /tasks` | Listar las tareas. |
| `GET /tasks/:id` | Consultar el detalle de una tarea. |
| `POST /tasks` | Crear una tarea. |
| `PATCH /tasks/:id` | Actualizar los campos de una tarea. |
| `DELETE /tasks/:id` | Eliminar una tarea. |

La aplicación usa datos locales durante la sesión 5. Estas rutas describen las operaciones que deberá ofrecer la API cuando se integre.
