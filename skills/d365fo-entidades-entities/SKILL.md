---
name: d365fo-entidades-entities
description: "Crea o extiende data entities de D365 F&O para integración, OData e importación/exportación. Incluye extensiones de entidades estándar, Chain of Command cuando sea viable, campos, mapeo, validación y compatibilidad."
argument-hint: "Describe el consumidor, entidad, campos, dirección del flujo y contrato requerido"
---

# D365 F&O — Data entities

Diseña entidades como contratos de integración mantenibles, no como una exposición accidental del esquema interno.

## Análisis

Confirma consumidor y mecanismo (OData, Data Management, integración), dirección, clave, granularidad, ámbito de compañía, volumen, frecuencia, seguridad y compatibilidad requerida. Identifica si existe una entidad estándar extensible adecuada.

## Implementación

- Extiende la entidad estándar cuando el punto de extensión lo soporte; evita duplicarla o modificarla por overlay.
- Añade campos y mapeos coherentes con tablas, EDTs, relaciones y semántica del contrato.
- Usa CoC o eventos solo sobre métodos/extension points soportados; no inventes hooks.
- Valida valores en el límite adecuado y entrega errores útiles al consumidor.
- Considera claves naturales, upsert, duplicados, idempotencia, orden de entidades, staging y comportamiento multi-compañía.
- No expongas datos sensibles ni campos internos sin justificación y permisos.

## Verificación

Compila y sincroniza metadata si se requiere; valida publicación, lectura/escritura, filtros, permisos, compañía y errores con datos representativos. Revisa compatibilidad de consumidores existentes y documenta cualquier cambio de contrato.
