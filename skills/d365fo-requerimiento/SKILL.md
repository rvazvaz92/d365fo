---
name: d365fo-requerimiento
description: "Analiza documentos de definición funcional (DDF), historias de usuario y solicitudes para D365 F&O. Extrae estructura, alcance, reglas, dependencias, supuestos y criterios de aceptación. Úsalo para revisar o preparar requerimientos antes de estimar o desarrollar."
argument-hint: "Comparte el DDF o historia de usuario y el módulo de Finance & Operations"
---

# D365 F&O — Análisis de requerimientos

## Entregable obligatorio: archivo .txt (prioridad 01)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento de origen (créala si no existe). Si no hay documento de origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `01_d365fo-requerimiento_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, ruta de la fuente), qué se revisó y qué no pudo revisarse (por ejemplo imágenes ilegibles o secciones vacías), el resultado completo de esta skill, preguntas abiertas y la siguiente skill de la cadena.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

## Encadenamiento automático

Cuando la fuente sea un DDF o historia de usuario, al terminar y guardar el `.txt` **continúa sin pedir confirmación** con:

1. `d365fo-analisis` (usa la misma fuente y el `.txt` 01 como insumo).
2. `d365fo-test-case` (usa la fuente, el `.txt` 01 y el `.txt` 02).

Cada skill genera su propio `.txt`. Pasa a las siguientes skills el mismo modelo (no lo vuelvas a preguntar). Si el usuario pide explícitamente solo esta skill, no encadenes. Al final resume los tres entregables y sus rutas.

Convierte DDF e historias de usuario en requerimientos claros, trazables y verificables. Responde en español. No inventes reglas ni completes vacíos funcionales con supuestos silenciosos.

## Flujo

1. Identifica objetivo de negocio, actores, módulo, proceso y entidades legales involucradas.
2. Extrae alcance, fuera de alcance, reglas de negocio, datos de entrada/salida, seguridad, dependencias y restricciones.
3. Descompón el requerimiento en comportamiento observable y criterios de aceptación comprobables.
4. Marca contradicciones, términos ambiguos, datos faltantes, riesgos y decisiones pendientes. Formula preguntas puntuales si impiden definir el comportamiento.
5. Relaciona el requerimiento con posibles artefactos F&O solo como hipótesis a investigar; no asumas que una implementación específica ya fue validada.

## Entrega

- Resumen funcional y objetivo.
- Alcance y exclusiones.
- Reglas y criterios de aceptación numerados.
- Actores, compañías, datos y permisos relevantes.
- Dependencias, riesgos, supuestos explícitos y preguntas abiertas.
- Trazabilidad entre cada historia/requisito y sus criterios.

Mantén el lenguaje del negocio y separa claramente lo explícito de lo inferido. Aún no diseñes ni escribas código X++ salvo que el usuario lo solicite.

## Reglas aprendidas: seguimiento de la logica del requerimiento

- Un requerimiento describe lo que el usuario debe poder hacer, no el punto tecnico donde se captura. Antes de implementar, reconstruir el flujo de punta a punta: por donde se crea o modifica realmente el registro, en que tabla trabaja cada formulario y en que orden se insertan las tablas.
- Caso (GRWCXC_99_CustFiscalInfo): el requerimiento pedia validar RFC, regimen fiscal y uso CFDI al crear o modificar un cliente. Se implemento la validacion en `CustTable`, pero el alta rapida de cliente (`DirPartyQuickCreateForm`) trabaja sobre `DirPartyTable`, que se inserta antes que el cliente; los datos fiscales no existian al capturar. Hubo que agregar campos a `DirPartyTable`, una extension del formulario, un lookup por event handler y validar despues del `next insert`.
- Esos cambios no estaban en el requerimiento original. Cada vez que la implementacion exija objetos o formularios que el requerimiento no menciona, registrarlo como **cambio de alcance** y avisar a consultoria o al responsable funcional antes de construirlo, no despues. Quedo como control de cambios de consultoria.
- Preguntar al inicio, por cada dato requerido: en que pantalla se captura, quien lo captura, si existen varias pantallas de alta (formulario completo, creacion rapida, importacion masiva por entidad) y en que tabla vive cada una.
- Incluir en el analisis los puntos de entrada alternativos al mismo dato (alta rapida, alta completa, carga por entidad de datos, integraciones) y marcar cuales quedan cubiertos y cuales no.
- Contrastar cada criterio de aceptacion con el flujo tecnico real: si un criterio dice "antes de guardar", confirmar que el dato existe en ese momento.
- Los pendientes sin respuesta (por ejemplo, filtrar por estado de la orden o validar siempre al confirmar) se registran como preguntas abiertas y no se resuelven por suposicion.
