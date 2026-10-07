---
name: d365fo-seguridad-privilegios
description: "Diseña y revisa la seguridad de D365 F&O con roles, duties, privileges, entry points y permisos de datos, aplicando mínimo privilegio. Úsalo para habilitar acceso a formularios, reportes, entidades, servicios y procesos."
argument-hint: "Indica la operación que debe autorizarse, usuarios/roles y datos que deben protegerse"
---

# D365 F&O — Seguridad y privilegios

## Entregable obligatorio: archivo .txt (prioridad 11)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Nombre:** `11_d365fo-seguridad-privilegios.txt`. Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, privilegios/duties/roles definidos con sus permisos (Leer/Actualizar/Crear/Eliminar), entry points cubiertos, pruebas de acceso y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Concede únicamente los permisos necesarios para una tarea de negocio identificada. Responde en español y comprueba tanto acceso permitido como denegado.

## Flujo

1. Identifica el entry point y la operación: menú, formulario, reporte, servicio, entidad u objeto ejecutable.
2. Determina qué rol/duty existente se ajusta y si corresponde crear un privilegio nuevo.
3. Incluye solo permisos requeridos y sigue la arquitectura de seguridad del proyecto.
4. Considera permisos de lectura/escritura, acceso de entidad/API, compañía y datos sensibles.
5. Verifica el acceso efectivo con los roles pertinentes; no confíes solo en que los metadatos compilan.

No otorgues System Administrator como workaround, no amplíes permisos globales sin necesidad y no des por protegida una API solo porque su formulario está restringido. Entrega artefactos de seguridad, alcance y pruebas de acceso positivo/negativo.
