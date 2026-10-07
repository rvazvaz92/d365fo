---
name: d365fo-proyecto-solucion
description: "Analiza la arquitectura y solución existente de un proyecto D365 F&O: modelos, paquetes, dependencias, artefactos, extensiones y convenciones. Úsalo para entender el estado actual antes de proponer cambios o estimar impacto."
argument-hint: "Indica el repositorio, modelo/paquete y la pregunta sobre la solución actual"
---

# D365 F&O — Análisis de proyecto y solución

## Entregable obligatorio: archivo .txt (prioridad 05)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Nombre:** `05_d365fo-proyecto-solucion.txt`. Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, rutas inspeccionadas), qué se revisó y qué no pudo revisarse, arquitectura y flujo encontrados con rutas/nombres exactos, riesgos y preguntas abiertas.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Investiga cómo está construida la solución actual y presenta evidencia antes de proponer cambios. Responde en español.

## Inspección

- Identifica modelos, paquetes, referencias, estructura, nomenclatura y patrones existentes.
- Ubica artefactos relacionados con la funcionalidad (tablas, extensiones, clases, entidades, formularios, reportes, seguridad, pruebas).
- Sigue llamadas y dependencias relevantes; distingue objetos estándar de extensiones personalizadas.
- Evalúa puntos de extensión soportados, riesgos de upgrade, seguridad, rendimiento, compañía e integración.
- Registra brechas de compilación/pruebas solo si fueron observadas o ejecutadas.

## Entrega

Resume arquitectura relevante, flujo actual, objetos controladores, dependencias, convenciones y riesgos. Incluye rutas/nombres exactos como evidencia cuando el entorno permita inspeccionarlos. Propón el cambio mínimo compatible con la solución existente. No hagas cambios ni atribuyas problemas al código sin evidencia.
