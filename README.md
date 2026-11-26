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

El usuario objetivo es un estudiante que organiza el trabajo semanal de su proyecto. Desde la sesión 7 puede consultar tareas de la API de práctica y abrir sus detalles. La sesión 9 incorpora un formulario para preparar una tarea nueva. Las cinco tareas originales quedan disponibles en el repositorio local. La creación remota, edición y eliminación se implementarán en sesiones posteriores.

### Historias de usuario y criterios de aceptación

1. Como estudiante, quiero listar mis tareas para decidir en qué trabajar primero. **Criterio de aceptación.** La lista muestra las tareas de la fuente configurada en tarjetas con título, prioridad e icono de estado.
2. Como estudiante, quiero consultar una tarea para leer sus instrucciones. **Criterio de aceptación.** Al tocar una tarjeta, su detalle muestra el identificador, título, descripción, prioridad, estado y usuario de esa tarea.
3. Como estudiante, quiero crear una tarea para registrar una actividad nueva. **Criterio de aceptación.** Al guardar un formulario con título, descripción y prioridad válidos, la nueva tarea aparece como pendiente en la lista.
4. Como estudiante, quiero editar una tarea para actualizar sus datos si cambian las instrucciones. **Criterio de aceptación.** Tras guardar un cambio de título, el nuevo título aparece en la lista y en el detalle de la misma tarea.
5. Como estudiante, quiero eliminar una tarea terminada para despejar la lista. **Criterio de aceptación.** Después de confirmar la eliminación, la tarjeta de esa tarea desaparece.

### Pantallas previstas

| Pantalla | Contenido y acciones |
| --- | --- |
| Lista | Tarjetas con título, prioridad y estado. Desde cada tarjeta se abre el detalle. **Nueva tarea** abre el formulario. |
| Detalle | Identificador, título, descripción, prioridad, estado y usuario de la tarea elegida. Las acciones de editar y eliminar quedan previstas. |
| Formulario | Valida título, descripción y prioridad para preparar una tarea nueva. Permite elegir una fecha opcional. |

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

`Task.fromJson` acepta este formato local y el formato de la API de práctica descrito más abajo. Este ejemplo representa una tarea completada del listado local.

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

Estas rutas describen las operaciones previstas para la API del proyecto.

### API de práctica

TaskFlow ejecuta `GET /todos?userId=2` en JSONPlaceholder. El parámetro `userId=2` limita la respuesta a las tareas del segundo usuario de prueba. La constante `TaskApiService.userId` configura ese filtro. [Endpoint de JSONPlaceholder](https://jsonplaceholder.typicode.com/todos?userId=2)

La respuesta incluye `id`, `userId`, `title` y `completed`. `Task.fromJson` convierte `completed` en `isCompleted` y usa `Sin descripción (API)` y `Sin prioridad (API)` para los campos ausentes. La consola registra `GET /todos?userId=2 → HTTP 200` cuando la consulta se atiende correctamente.

`TaskApiService` conoce la URL y convierte el JSON en objetos `Task`. `RemoteTaskRepository` conserva una copia en memoria y `TasksViewModel` avisa a la lista y al detalle. Marcar una tarea cambia esa copia durante la ejecución. Al reiniciar la app, vuelve a mostrarse el estado recibido de la API.

### Estados de la lista remota

| Estado | Cómo provocarlo y qué observar |
| --- | --- |
| Carga | Limita la velocidad de la red del emulador o navegador y pulsa el icono **Actualizar tareas**. Mientras la consulta está pendiente aparece un indicador y el icono queda deshabilitado. |
| Éxito | Con conexión y `userId=2`, inicia la app. Abre una tarjeta y comprueba que el detalle corresponde a esa tarea. Vuelve a la lista y desliza hacia abajo para consultar de nuevo. |
| Vacío | Cambia temporalmente `TaskApiService.userId` a `9999` y reinicia la app. La API devuelve una lista vacía y se muestra «Todavía no hay tareas para mostrar» con el botón **Actualizar**. Restablece `userId=2` al terminar. |
| Error y reintento | Con la app abierta, interrumpe la conexión y pulsa **Actualizar tareas**. Cuando aparezca «No se pudieron cargar las tareas», restablece la conexión y pulsa **Reintentar**. La lista vuelve a aparecer en la misma ejecución. |

Actualizar vuelve a leer el estado del servidor y reemplaza las marcas que se hicieron en memoria.

### Formulario de nueva tarea

Desde **Mis tareas**, pulsa **Nueva tarea**. El título requiere al menos tres caracteres y la descripción debe tener contenido. Ambos se guardan sin espacios al inicio o al final. La prioridad inicial es **Media** y se puede cambiar a **Alta** o **Baja**. El calendario está en español y la fecha se puede quitar después de seleccionarla.

Al pulsar **Guardar**, la validación mantiene el formulario abierto si hay errores. Con datos válidos, la lista recibe el borrador temporal y muestra «Formulario válido» junto al título. **Cancelar** vuelve a la lista sin mensaje. El envío a la API mediante `POST` corresponde a la sesión 10.
