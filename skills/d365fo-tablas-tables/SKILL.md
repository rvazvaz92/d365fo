---
name: d365fo-tablas-tables
description: "Diseña y modifica tablas y extensiones de tabla en D365 F&O: campos, EDTs, relaciones, índices, validaciones y métodos de negocio. Úsalo para modelar o extender datos respetando integridad y rendimiento."
argument-hint: "Describe los datos, cardinalidad, compañía, reglas e integraciones que debe soportar la tabla"
---

# D365 F&O — Tablas y modelado de datos

## Entregable obligatorio: archivo .txt (prioridad 07)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Nombre:** `07_d365fo-tablas-tables.txt`. Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, tablas/campos/EDTs/relaciones/índices definidos o modificados, impacto en datos existentes, validación y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Modela datos con semántica correcta, integridad referencial y compatibilidad con el patrón existente. Prefiere una extensión soportada y evita overlayering.

## Antes de cambiar

Determina propiedad y cardinalidad del dato, ámbito global o por compañía, lifecycle, volumen, consumidores y posibilidad de extender un objeto estándar. Reutiliza EDTs y patrones existentes cuando representen correctamente el dato.

## Revisa

- EDT, tipo, tamaño, etiqueta, ayuda y valor por defecto.
- Relaciones, delete actions, índices y unicidad conforme a reglas reales.
- Métodos de validación/invariantes en la tabla o capa propietaria.
- `SaveDataPerCompany`, `DataAreaId` y contexto legal si corresponde.
- Impacto en data entities, formularios, reportes, seguridad, integraciones y migración de datos.
- Concurrencia, índices y coste de consultas con volumen esperado.

## Validación y entrega

Ejecuta compilación y sincronización de metadata/base de datos solo cuando aplique; prueba inserción, actualización, validación, relaciones y compañía. Informa impacto de datos existente y prerrequisitos de despliegue. No uses campos/relaciones supuestos sin confirmar el modelo.
