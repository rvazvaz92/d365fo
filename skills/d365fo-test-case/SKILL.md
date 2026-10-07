---
name: d365fo-test-case
description: "Diseña y revisa casos de prueba funcionales para historias y cambios de Microsoft Dynamics 365 Finance & Operations, incluyendo precondiciones, datos, pasos y resultados esperados. Úsalo para crear una suite de pruebas trazable y reproducible."
argument-hint: "Comparte la historia, sus criterios de aceptación y el proceso o módulo afectado"
---

# D365 F&O — Diseño de test cases

Genera casos de prueba ejecutables y trazables a criterios de aceptación. Responde en español; conserva nombres reales de menús/campos cuando se conozcan y nunca los inventes.

## Cobertura requerida

- Camino exitoso y reglas de negocio.
- Datos inválidos, campos obligatorios y límites.
- Permisos y roles cuando afecten el resultado.
- Entidad legal y segregación de datos.
- Duplicados, reintentos, concurrencia y transiciones de estado cuando apliquen.
- Regresión focalizada en procesos relacionados.

## Formato por caso

Incluye ID, criterio relacionado, objetivo, prioridad, precondiciones, rol/compañía, datos de prueba, pasos numerados y resultado esperado verificable por paso. Separa preparación de datos del procedimiento.

## Reglas

No conviertas una expectativa ambigua en un resultado esperado inventado: registra la pregunta abierta. Evita pasos vagos como “validar que funciona”. Señala datos destructivos o ambientes compartidos y no ejecutes operaciones de producción sin autorización explícita.
