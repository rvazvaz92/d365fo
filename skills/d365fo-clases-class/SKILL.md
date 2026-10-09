---
name: d365fo-clases-class
description: "Diseña, genera, extiende y revisa clases X++ de D365 F&O, incluyendo clases estándar extensibles, Chain of Command, event handlers y SysOperation. Úsalo para lógica de negocio, servicios, controladores y procesos."
argument-hint: "Describe el proceso, artefacto estándar, extensión disponible y comportamiento esperado"
---

# D365 F&O — Clases X++

## Entregable obligatorio: archivo .txt (prioridad 06)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `06_d365fo-clases-class_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
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

## Reglas aprendidas: nombre de extensiones de clase y de objetos estandar

- Patron: GRW<ObjetoEstandar>_<Modelo>_Extension (ej. GRWClase_IDDF_Extension, GRWCustTable_CXC_99_Extension). Archivo AxClass\<Nombre>.xml y Name igual.
- Atributo segun el objeto: [ExtensionOf(tableStr(CustTable))], classStr, formStr o formDataSourceStr; clase final; CoC con next; metodos de apoyo private con prefijo grw.
- Al renombrar: cambiar archivo, Name, declaracion y .rnrproj (Content Include="AxClass\<Nombre>", Link Classes\), y borrar el anterior en K: y en el repo.
- Ejemplo: GRWCustTable_CXC_99_Extension aplica validateWrite y validateField de CustTable segun CustParameters.GRWCustFiscalValidate (Rfc_MX, TaxRegimeCode_MX y SATPurpose_MX obligatorios; duplicidad de RFC salvo los de GRWCustRFCCatalog). Sin compilar.
- Pendiente de confirmar: si CXC_99 es el codigo fijo del modelo o varia por proyecto.
