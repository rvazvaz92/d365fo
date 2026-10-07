---
name: d365fo-clases-class
description: "Diseña, genera, extiende y revisa clases X++ de D365 F&O, incluyendo clases estándar extensibles, Chain of Command, event handlers y SysOperation. Úsalo para lógica de negocio, servicios, controladores y procesos."
argument-hint: "Describe el proceso, artefacto estándar, extensión disponible y comportamiento esperado"
---

# D365 F&O — Clases X++

## Entregable obligatorio: archivo .txt (prioridad 06)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Nombre:** `06_d365fo-clases-class.txt`. Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, clases/métodos afectados, patrón elegido, código propuesto o cambios realizados, validación ejecutada y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Implementa clases X++ siguiendo el modelo/paquete, las convenciones cercanas y los patrones soportados de la plataforma.

## Selección del patrón

- CoC para añadir lógica a un método extensible y conservar el flujo base con `next` donde corresponda.
- Event handler/delegate para reaccionar sin apropiarse del flujo.
- SysOperation con contrato, servicio y controller para operaciones de negocio ejecutables/interactivas o batch.
- No uses RunBaseBatch para código nuevo salvo que la solución mantenga deliberadamente ese patrón.

## Calidad

Define responsabilidades y visibilidad explícitas; valida entradas en el límite correcto; maneja errores sin ocultarlos; evita estado global y consultas repetidas. Mantén transacciones mínimas, consultas selectivas y lógica consciente de compañía. Revisa idempotencia y reintentos si la clase se invoca desde batch/integración.

## Validación

Inspecciona llamadas y extensión disponible antes de generar código. Compila el artefacto afectado, ejecuta pruebas focalizadas y cubre éxito, error y regresión pertinente. Explica archivos/clases tocados y APIs o requisitos de despliegue pendientes. Nunca inventes firmas de métodos estándar.
