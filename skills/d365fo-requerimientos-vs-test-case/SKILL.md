---
name: d365fo-requerimientos-vs-test-case
description: "Valida la trazabilidad y cobertura entre requerimientos, historias de usuario y casos de prueba de D365 F&O. Detecta criterios sin pruebas, pruebas sin requisito y resultados esperados que no corresponden a la historia."
argument-hint: "Comparte los requerimientos o historias junto con los casos de prueba"
---

# D365 F&O — Trazabilidad de requerimientos y pruebas

## Entregable obligatorio: archivo .txt (prioridad 04)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento de origen (créala si no existe). Si no hay documento de origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `04_d365fo-requerimientos-vs-test-case_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, rutas de las fuentes), qué se revisó y qué no pudo revisarse, la matriz de trazabilidad, brechas y preguntas abiertas.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Compara requerimientos e historias con test cases sin asumir que la existencia de una prueba implica cobertura correcta.

## Método

1. Extrae requisitos, criterios de aceptación y casos de prueba con sus IDs.
2. Relaciona cada criterio con uno o más casos y cada caso con el requisito que verifica.
3. Comprueba que pasos, datos y resultados esperados prueben el comportamiento indicado, incluyendo variantes y errores.
4. Detecta requisitos sin cobertura, casos huérfanos, cobertura parcial, pruebas duplicadas y expectativas contradictorias.
5. Verifica aspectos F&O pertinentes: compañía, rol, datos maestros, estado del proceso, integración y regresión.

## Entrega

Incluye matriz de trazabilidad (requisito/criterio, casos, estado de cobertura, observación), lista priorizada de brechas y cambios concretos sugeridos. Usa “no verificable” cuando falte información; no inventes IDs ni declares cobertura total con evidencia incompleta.
