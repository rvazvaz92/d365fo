---
name: d365fo-analisis
description: "Analiza historias de usuario, solicitudes o procesos de D365 F&O para determinar si tienen sentido funcional y técnico, identificar mejoras, huecos, riesgos y posibles problemas antes de implementar. Úsalo para análisis y recomendaciones, no para modificar código sin solicitarlo."
argument-hint: "Describe o comparte la historia, el proceso actual y el resultado esperado"
---

# D365 F&O — Análisis de historia y solución

## Entregable obligatorio: archivo .txt (prioridad 02)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento de origen (créala si no existe). Si no hay documento de origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `02_d365fo-analisis_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, ruta de la fuente), qué se revisó y qué no pudo revisarse, hallazgos priorizados, mejoras, riesgos, preguntas abiertas y la siguiente skill de la cadena.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

## Encadenamiento automático

- **Entrada:** si existe el `01_d365fo-requerimiento_<MODELO>.txt` de la misma fuente y del mismo modelo, úsalo como insumo y no repitas la extracción; verifica contra la fuente cuando algo no cuadre.
- **Salida:** al terminar y guardar el `.txt`, **continúa sin pedir confirmación** con `d365fo-test-case`, salvo que el usuario haya pedido solo esta skill.

Analiza la solicitud desde las perspectivas funcional, técnica y operativa. Responde en español y distingue hechos, inferencias y preguntas.

## Revisión

1. Resume el problema y el resultado de negocio esperado.
2. Comprueba coherencia, actores, estados, datos, reglas, excepciones y criterios de aceptación.
3. Identifica casos límite, duplicidad, concurrencia, multi-compañía, seguridad, rendimiento y efectos en integraciones/reportes.
4. Señala contradicciones, dependencias, riesgos de upgrade y supuestos no confirmados.
5. Propón mejoras ordenadas por impacto y esfuerzo; indica qué decisiones requieren confirmación.
6. Si hay solución existente, compara el comportamiento requerido con evidencia del código/metadata y evita recomendar reescrituras innecesarias.

## Entrega

Presenta: entendimiento, hallazgos priorizados, oportunidades de mejora, riesgos, preguntas abiertas y una recomendación concreta. No afirmes que una propuesta es compatible con F&O hasta verificar extensibilidad, APIs y convenciones del modelo. No cambies archivos salvo que el usuario pida implementación.

## Aportes del merge (ddf-analisis-d365fo)

Sigue las reglas de .github/copilot-instructions.md y el formato de salida de .github/prompts/ddf-analisis.prompt.md.

Regla absoluta: esta etapa es SOLO de análisis. No crees, edites ni borres archivos; no modifiques el `.rnrproj`; no ejecutes comandos que escriban nada. Solo se permite LEER (DDF, modelos en `K:`, estándar) para fundamentar la propuesta. Ningún proceso de construcción arranca hasta que el usuario apruebe el diseño de forma explícita.

Reglas clave:
1. No escribas código X++ ni XML en esta etapa.
2. Propón el mínimo de objetos; lo opcional va aparte.
3. Verifica en lectura los nombres estándar (`ApplicationSuite\Foundation`, con `Select-String`/`Get-Content -TotalCount`, nunca lecturas completas); si no puedes verificarlos, márcalos con ⚠️.
4. Antes de proponer un objeto nuevo, busca si ya existe en `GRWEstevez`, `GRWVenegas` o el estándar; si existe, reutilízalo o cítalo como referencia.
5. Pregunta el modelo destino (por defecto `GRWEstevez`) y confirma la solución/`.rnrproj` en curso (actual: `GRWOVE11_CustomerOrderFieldValidation`).
6. Máximo 8 preguntas al funcional, solo las que cambian el diseño; marca cada una como "bloquea diseño" o "no bloquea".
7. Cada objeto propuesto indica la skill que lo construirá: `d365fo-tablas`, `d365fo-formularios`, `d365fo-clases` o `d365fo-reportes`.
8. Labels: ID `GRW<Req>` con guion bajo (OVE_11 → `GRWOVE_11`), referencia `@GRWOVE_11:<Id>`; el contenido se define con `xpp-labels-d365fo` y los archivos con `d365fo-labels`.
9. Seguridad: aplica la matriz de `d365fo-privilegios` (tipo de menú, `View`/`Maintain`, permisos) o indica "No aplica" si solo hay tablas/clases/EDT/enums. No propongas duties ni roles.
10. Validaciones: el flujo indica `checkFailed` y `return false`.
11. Incluye la trazabilidad Requerimiento → Objeto → Prueba y el plan de construcción por fases.
12. Termina preguntando si se aprueba el diseño y aclara que NO se ejecutará nada hasta recibir la aprobación. Tras la aprobación continúan `d365fo-requerimiento`/`d365fo-proyecto` y, al final, `ddf-documentacion-tecnica`.
