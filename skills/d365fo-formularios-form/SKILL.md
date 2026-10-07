---
name: d365fo-formularios-form
description: "Diseña, extiende y depura formularios de Microsoft Dynamics 365 Finance & Operations usando extensiones y patrones de UI soportados. Úsalo para controles, datasource, eventos, acciones, validaciones y presentación."
argument-hint: "Describe el formulario, el usuario/rol, la acción y el resultado esperado"
---

# D365 F&O — Formularios

Implementa cambios de UI sin trasladar reglas de negocio al control cuando pertenecen a una tabla o servicio.

## Investiga

Ubica formulario, datasources, controles, extensiones existentes, menú/entry point, seguridad y lógica invocada. Confirma si la regla es visual o una invariante de negocio.

## Implementa

- Usa form extensions y eventos soportados; evita overlay.
- Mantén handlers pequeños y delega lógica de negocio.
- Respeta datasource, cursor, `forUpdate`, validación y ciclo de vida del formulario.
- Controla estados vacíos, carga, error, éxito, selección y acciones repetidas.
- Asegura que mensajes sean accionables y que el usuario no pueda eludir validación mediante otra ruta.
- Verifica permisos y no expongas datos que el rol no debe ver.

## Pruebas

Prueba el flujo UI completo con roles/datos representativos, estados de validación y regresión relacionada. Ejecuta automatización de UI solo si el entorno la soporta. Reporta qué se probó visual y funcionalmente; no declares pruebas de navegador si no se realizaron.
