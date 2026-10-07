---
name: d365fo-formularios-form
description: "Diseña, extiende y depura formularios de Microsoft Dynamics 365 Finance & Operations usando extensiones y patrones de UI soportados. Úsalo para controles, datasource, eventos, acciones, validaciones y presentación."
argument-hint: "Describe el formulario, el usuario/rol, la acción y el resultado esperado"
---

# D365 F&O — Formularios

## Entregable obligatorio: archivo .txt (prioridad 09)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `09_d365fo-formularios-form_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, formularios/controles/datasources y patrón aplicado, cambios, pruebas de UI realizadas y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

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
