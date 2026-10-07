---
name: d365fo-seguridad-privilegios
description: "Diseña y revisa la seguridad de D365 F&O con roles, duties, privileges, entry points y permisos de datos, aplicando mínimo privilegio. Úsalo para habilitar acceso a formularios, reportes, entidades, servicios y procesos."
argument-hint: "Indica la operación que debe autorizarse, usuarios/roles y datos que deben protegerse"
---

# D365 F&O — Seguridad y privilegios

Concede únicamente los permisos necesarios para una tarea de negocio identificada. Responde en español y comprueba tanto acceso permitido como denegado.

## Flujo

1. Identifica el entry point y la operación: menú, formulario, reporte, servicio, entidad u objeto ejecutable.
2. Determina qué rol/duty existente se ajusta y si corresponde crear un privilegio nuevo.
3. Incluye solo permisos requeridos y sigue la arquitectura de seguridad del proyecto.
4. Considera permisos de lectura/escritura, acceso de entidad/API, compañía y datos sensibles.
5. Verifica el acceso efectivo con los roles pertinentes; no confíes solo en que los metadatos compilan.

No otorgues System Administrator como workaround, no amplíes permisos globales sin necesidad y no des por protegida una API solo porque su formulario está restringido. Entrega artefactos de seguridad, alcance y pruebas de acceso positivo/negativo.
