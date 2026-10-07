---
name: d365fo-test-case
description: "Diseña y revisa casos de prueba funcionales para historias y cambios de Microsoft Dynamics 365 Finance & Operations, incluyendo precondiciones, datos, pasos y resultados esperados. Úsalo para crear una suite de pruebas trazable y reproducible."
argument-hint: "Comparte la historia, sus criterios de aceptación y el proceso o módulo afectado"
---

# D365 F&O — Diseño de test cases

## Entregable obligatorio: archivo .txt (prioridad 03)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento de origen (créala si no existe). Si no hay documento de origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `03_d365fo-test-case_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, ruta de la fuente), qué se revisó y qué no pudo revisarse, la suite de casos completa, preguntas abiertas y la siguiente skill sugerida.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

## Encadenamiento automático

- **Entrada:** usa los `.txt` 01 y 02 de la misma fuente y del mismo modelo si existen, y verifica contra la fuente cuando algo no cuadre.
- **Salida:** es el final de la cadena automática. Al terminar, solo **sugiere** `d365fo-requerimientos-vs-test-case` para validar la trazabilidad; no la ejecutes sin que el usuario lo pida.

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
