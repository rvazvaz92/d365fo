---
name: d365fo-errores-encontrados
description: "Documenta errores reales encontrados y corregidos en soluciones D365 F&O/X++ como una base de conocimiento tipo wiki, con causa raíz, evidencia, solución, validación y prevención. Úsalo al depurar o cuando el usuario solicite registrar una lección técnica."
argument-hint: "Comparte el error, contexto, causa confirmada, solución y pruebas realizadas"
---

# D365 F&O — Wiki de errores y soluciones

## Entregable obligatorio: archivo .txt (prioridad 13)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `13_d365fo-errores-encontrados_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, las entradas de wiki registradas o actualizadas con el formato de esta skill y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Construye una base de conocimiento útil y verificable de problemas X++ y D365 F&O. No registres credenciales, datos personales ni secretos. No conviertas hipótesis no confirmadas en soluciones.

## Registro de cada caso

Incluye:

- ID/título descriptivo y fecha, si se conoce.
- Versión/plataforma, módulo, objeto y contexto mínimo reproducible.
- Mensaje/código exacto del error, eliminando datos sensibles.
- Síntoma, impacto, precondiciones y alcance.
- Causa raíz confirmada y evidencia; etiqueta como hipótesis si no se confirmó.
- Solución aplicada, alternativas descartadas y artefactos afectados.
- Validaciones ejecutadas y resultado real.
- Prevención, workaround temporal y riesgos/dependencias pendientes.
- Etiquetas de búsqueda (por ejemplo: compilación, CoC, SysOperation, entidad, batch, seguridad, rendimiento).

## Mantenimiento

Antes de agregar una entrada, busca duplicados y enlaza casos relacionados. Conserva historial de cambios cuando exista documentación previa; no sobrescribas conclusiones válidas silenciosamente. Usa el formato de documentación que ya tenga el repositorio. Si no existe, solicita o acuerda ubicación/formato antes de crear una wiki persistente. Nunca afirmes que un error fue solucionado sin validación documentada.
