---
name: d365fo-tablas-tables
description: "Diseña y modifica tablas y extensiones de tabla en D365 F&O: campos, EDTs, relaciones, índices, validaciones y métodos de negocio. Úsalo para modelar o extender datos respetando integridad y rendimiento."
argument-hint: "Describe los datos, cardinalidad, compañía, reglas e integraciones que debe soportar la tabla"
---

# D365 F&O — Tablas y modelado de datos

## Entregable obligatorio: archivo .txt (prioridad 07)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `07_d365fo-tablas-tables_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, tablas/campos/EDTs/relaciones/índices definidos o modificados, impacto en datos existentes, validación y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Modela datos con semántica correcta, integridad referencial y compatibilidad con el patrón existente. Prefiere una extensión soportada y evita overlayering.

## Antes de cambiar

Determina propiedad y cardinalidad del dato, ámbito global o por compañía, lifecycle, volumen, consumidores y posibilidad de extender un objeto estándar. Reutiliza EDTs y patrones existentes cuando representen correctamente el dato.

## Revisa

- EDT, tipo, tamaño, etiqueta, ayuda y valor por defecto.
- Relaciones, delete actions, índices y unicidad conforme a reglas reales.
- Métodos de validación/invariantes en la tabla o capa propietaria.
- `SaveDataPerCompany`, `DataAreaId` y contexto legal si corresponde.
- Impacto en data entities, formularios, reportes, seguridad, integraciones y migración de datos.
- Concurrencia, índices y coste de consultas con volumen esperado.

## Validación y entrega

Ejecuta compilación y sincronización de metadata/base de datos solo cuando aplique; prueba inserción, actualización, validación, relaciones y compañía. Informa impacto de datos existente y prerrequisitos de despliegue. No uses campos/relaciones supuestos sin confirmar el modelo.

## Codificación de los XML de metadata (AxTable)

- **Síntoma:** al abrir una tabla en el diseñador de Visual Studio solo se ve el código X++ suelto y las propiedades concatenadas, aunque el XML parezca íntegro en el editor.
- **Causa típica:** el archivo se guardó en Windows-1252 (ANSI) pero declara `encoding="utf-8"`. Los caracteres con acento (é, á, ó, ñ), por ejemplo en `HelpText` o `Label`, quedan como bytes inválidos en UTF-8 y el XML ya no se interpreta.
- **Cómo detectarlo:** busca bytes >= 128 que no formen secuencias UTF-8 válidas, o el carácter de reemplazo en el archivo.
- **Corrección:** reconvierte el archivo a UTF-8 con BOM sin cambiar el contenido y valida que cargue con `XmlDocument.Load`. Cierra y reabre la tabla en Visual Studio (o acepta recargar).
- **Prevención:** al editar metadata con herramientas externas o scripts, guarda siempre en UTF-8 (con BOM). No uses `Set-Content`/`Out-File` sin indicar la codificación.
- **Verificación posterior:** confirma que se conservan métodos, grupos de campos, campos, índices y relaciones (por ejemplo, en `GRWCustFiscalData`: `CustTable`, `EInvoiceExtCodeTable_MX_TaxRegime`, `EInvoiceExtCodeTable_MX_CFDIPurpose`).
- El `.xpp` en `bin\XppSource` es un derivado de compilación; el origen de verdad es el XML de `AxTable`.

## Métodos display en tablas (relacionado con `d365fo-formularios-form`)

Los métodos `display` de la tabla alimentan campos calculados en formularios. Esta skill define el método; el enlace con el control se documenta en `d365fo-formularios-form` (sección "Campos display en formularios").

- Declaración: `display <Tipo> nombreMetodo()`, sin parámetros; el tipo debe ser compatible con el control (`Description`, `Name`, `str`, `int`, `real`).
- Usa `select firstOnly` y evita consultas pesadas: se ejecuta en cada refresco del formulario. Si es costoso, cachea.
- Tabla estándar: usa extensión, `[ExtensionOf(tableStr(SalesTable))] final class SalesTable_Extension { display Name custName() {...} }`.
- Si el método consulta una tabla de códigos con varios tipos, filtra siempre por el tipo (ejemplo real en `GRWCustFiscalData`: `taxRegimeDescription()` y `cfdiPurposeDescription()` filtran `EInvoiceExtCodeTable_MX` por `CodeType`).
- No agregues el método a los campos del datasource del formulario; se enlaza en el control con `DataMethod`.
- Al crear un método display nuevo, revisa si ya hay formularios que deban mostrarlo y agrega la etiqueta del control.
- Archivos de metadata de tabla: guarda en UTF-8 (ver sección de codificación).

## Reglas aprendidas: staging de entidades custom

- Tabla con TableGroup=Staging, campos de sistema (DefinitionGroup, ExecutionId, IsSelected, TransferStatus), campos de la entidad e indice StagingIdx (DefinitionGroup, ExecutionId, llave). Relacion DataEntity hacia la entidad.
- Nombre: <TablaCustom>Staging. Tras cambiar campos de la entidad, regenerar el staging con el asistente.
- Las tablas se crean en el modelo: K:\AosService\PackagesLocalDirectory\<MODELO>\<MODELO>\AxTable.

- Label propio: toda tabla, staging y entidad custom lleva su propio label en el archivo del modelo (es-MX y en-US), nunca el estandar del asistente (ej. @SYS11307). Usar el siguiente numero libre y un label distinto para la entidad y para el staging (ej. <Prefijo>_026 entidad, <Prefijo>_027 staging). Reemplazar el label por defecto que deja el asistente.

## Reglas aprendidas: extensiones de tabla y staging con prefijo GRW

- Todo campo nuevo en una extension de tabla estandar o en una staging lleva prefijo GRW (ej. GRWCustFiscalValidate en CustParameters, GRWSATPurpose_MX en CustCustomerV3Staging). Los campos estandar que solo se leen o validan conservan su nombre (Rfc_MX, SATPurpose_MX, TaxRegimeCode_MX en CustTable).
- Estructura de AxTableExtension: Name = <Tabla>.<Modelo>; campos con i:type AxTableFieldString o AxTableFieldEnum, ExtendedDataType o EnumType y Label.
- Labels con prefijo @<ARCHIVO>: (ej. @CXC99:CXC99_039) y presentes en en-US y es-MX. Sin prefijo se muestra el texto literal (ocurrio en GRWCustFiscalValidate y en campos de GRWCustFiscalData). No reutilizar el label del formulario para un campo.
- Antes de agregar un campo estandar a una entidad o staging, buscar en AxTableExtension y AxDataEntityViewExtension del estandar (ApplicationSuite_MX_Extension): TaxRegimeCode_MX ya esta expuesto en CustCustomerV3Entity y en su staging; agregarlo con GRW duplica el dato.
- Table.validateWrite y validateField se ejecutan en formularios, X++, OData, Excel y DMF; en DMF depende de "Run business validations" en Entity structure. Si validateField falla, validateWrite no se llama.
- Registrar cada extension en el .rnrproj: Content Include="AxTableExtension\<Nombre>" con Link Table Extensions\<Nombre>.
- En la staging de una entidad estandar, el campo lleva el mismo nombre y el mismo EDT que en la entidad.
