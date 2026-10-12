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

- Patron: GRW<ObjetoEstandar>_<CodigoModelo>_Extension (ej. GRWClase_IDDF_Extension, GRWCustTable_CXC_99_Extension). Archivo AxClass\<Nombre>.xml y Name igual.
- Regla de nomenclatura: el codigo del modelo (IDDF, CXC_99, ...) cambia en cada modelo, porque todos los modelos son distintos. Nunca copiar el codigo de otro modelo ni asumir el de GRWCXC_99_CustFiscalInfo: tomalo del modelo en el que se trabaja, o confirmalo con el usuario si no es evidente. Los ejemplos de esta seccion son solo ilustrativos.
- Atributo segun el objeto: [ExtensionOf(tableStr(CustTable))], classStr, formStr o formDataSourceStr; clase final; CoC con next; metodos de apoyo private con prefijo grw.
- Al renombrar: cambiar archivo, Name, declaracion y .rnrproj (Content Include="AxClass\<Nombre>", Link Classes\), y borrar el anterior en K: y en el repo.
- Ejemplo: GRWCustTable_CXC_99_Extension aplica validateWrite y validateField de CustTable segun CustParameters.GRWCustFiscalValidate (Rfc_MX, TaxRegimeCode_MX y SATPurpose_MX obligatorios; duplicidad de RFC salvo los de GRWCustRFCCatalog). Sin compilar.
- Confirmado por el usuario: la nomenclatura de cualquier extension (clase, tabla, entidad, menu, formulario) varia segun el modelo; ver la regla de nomenclatura de esta seccion.

## Reglas aprendidas: event handlers solo si se piden explicitamente

- No usar event handlers (DataEventHandler, SubscribesTo, [FormEventHandler], etc.) por iniciativa propia. Solo se usan cuando el usuario lo indica de forma explicita.
- Por defecto, para anadir logica a un metodo extensible se usa CoC (ExtensionOf + next). Si el CoC no compila, no sustituirlo por un event handler sin permiso: informar el error y proponer alternativas.
- Caso registrado (GRWCXC_99_CustFiscalInfo): el CoC de SalesTable.validateWrite dio el error de compilacion "A reference to Dynamics.AX.Retail is required"; se sustituyo por un handler ValidatingWrite sin autorizacion y el usuario lo rechazo. La clase GRWSalesTable_CXC_99_Extension (CoC) se restauro. El error de referencia se resuelve con la referencia/cache del proyecto, no cambiando el patron.
- No borrar ni reescribir una clase CoC existente del usuario sin que lo pida. Cambiar solo la clase solicitada y no tocar lo ya hecho.
- No compilar salvo que el usuario lo pida: la compilacion la hace el usuario.
- Al escribir .rnrproj o XML de AxClass con PowerShell, no dejar saltos de linea antes de <?xml (rompe la carga del proyecto). Quitar con TrimStart([char]0xFEFF, "`r", "`n", " ") antes de WriteAllText con UTF8Encoding($true) y validar con XmlDocument.Load.

## Reglas aprendidas: CoC de CustTable.insert

- Firma del metodo extendido: `insert(DirPartyType _partyType = DirPartyType::None, Name _name = '', boolean _updateCRM = true)`. En el CoC se llama `next insert(_partyType, _name, _updateCRM)` con los tres argumentos; llamar `next insert()` sin parametros pierde tipo y nombre del party.
- El estandar abre su `ttsbegin` y hace `ttscommit` dentro de `insert`, y crea el party con `DirPartyTable::createNew(_partyType, _name)` solo si `this.Party` esta vacio. Ese `createNew` inserta el party solo con tipo y nombre, por eso los campos extra del party no existen en ese momento.
- Validar despues del `next` y detener la creacion: abrir `ttsbegin` ANTES del `next` y lanzar `throw error(...)` si falla; asi se revierte cliente y party. Si el `ttsbegin` va despues del `next`, el estandar ya confirmo y el error no revierte nada (salvo que exista una transaccion externa).
- Los campos fiscales asignados despues del `next` solo existen en memoria. Para guardarlos: hacer el metodo de validacion `boolean`, y si pasa, `this.doUpdate()` antes del `ttscommit`. `doUpdate()` no ejecuta `validateWrite`, `validateField` ni el `update` estandar; en Mexico el `update` de CustTable llama a `copyInfoToParty()`.
- Patron: `ttsbegin; next insert(...); if (!this.validate...()) { throw error(...); } this.doUpdate(); ttscommit;`.
- Precedencia en condiciones de `validateField`: `&&` se evalua antes que `||`; agrupar con parentesis cuando se mezclan parametros y varios campos.
- No fue compilado ni probado en ejecucion (caso GRWCXC_99_CustFiscalInfo).

## Reglas aprendidas: SalesFormLetter y estado del documento

- En `SalesFormLetter`, `documentStatus()` devuelve el tipo de documento que registra la subclase (ej. `SalesFormLetter_Confirm` devuelve `DocumentStatus::Confirmation`), NO el estado de la orden. El estado de la orden esta en `SalesTable.SalesStatus` y el ultimo documento registrado en `SalesTable.DocumentStatus`.
- Para validar al confirmar: CoC sobre `SalesFormLetter.validate(Object _calledFrom)` con `next validate(_calledFrom)` y condicion `this.documentStatus() == DocumentStatus::Confirmation`; las ordenes seleccionadas se obtienen con `this.getAllSalesTables()` y, si no hay, `this.salesTable()`.
- Si se necesita filtrar por estado de la orden (ej. solo Backorder), anadir la condicion sobre `SalesTable.SalesStatus` por cada orden; confirmar con el usuario si la reconfirmacion debe validarse.
- CoC directo sobre `SalesTable` puede pedir la referencia al modulo `Retail` (error "A reference to Dynamics.AX.Retail is required"); ver `d365fo-errores-encontrados`.
