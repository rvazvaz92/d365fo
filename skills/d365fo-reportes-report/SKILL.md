---
name: d365fo-reportes-report
description: "Diseña y depura reportes D365 F&O según su fuente de datos y modo de ejecución, incluidos SSRS/RDP, Query-based y reportes simples. Revisa contratos, consultas, parámetros, alineación de datos y rendimiento."
argument-hint: "Indica el reporte, fuente de datos, tipo de ejecución, filtros y salida requerida"
---

# D365 F&O — Reportes

Determina primero el tipo de reporte y el patrón ya usado por el proyecto. No presupongas que todos los reportes deben usar RDP ni que los datos pueden consultarse sin respetar compañía y permisos.

## Diseño

- Confirma fuente de datos, granularidad, filtros, parámetros, orden, agrupaciones, formato y destino.
- Elige Query-based, RDP u otro patrón soportado según la complejidad y la arquitectura existente.
- Mantén contrato entre controller/contract, DP/dataset y diseño alineado.
- Filtra temprano, evita consultas por fila, limita campos y controla volumen.
- Considera multi-compañía, datos vacíos, totales, moneda/fecha y seguridad.
- No escondas errores de ejecución ni presentes datos parciales como resultado exitoso.

## Validación

Compila el reporte y valida parámetros, filtros, datos representativos, resultados vacíos, totales/alineación y tiempos razonables. Confirma salida en el destino requerido y reporta limitaciones de ambiente o datos.
