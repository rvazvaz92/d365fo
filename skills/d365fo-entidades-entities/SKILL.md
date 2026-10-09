---
name: d365fo-entidades-entities
description: "Crea o extiende data entities de D365 F&O para integración, OData e importación/exportación. Incluye extensiones de entidades estándar, Chain of Command cuando sea viable, campos, mapeo, validación y compatibilidad."
argument-hint: "Describe el consumidor, entidad, campos, dirección del flujo y contrato requerido"
---

# D365 F&O — Data entities

## Entregable obligatorio: archivo .txt (prioridad 08)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `08_d365fo-entidades-entities_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, entidades y campos definidos o extendidos, contrato y mecanismos de consulta, validación y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Diseña entidades como contratos de integración mantenibles, no como una exposición accidental del esquema interno.

## Análisis

Confirma consumidor y mecanismo (OData, Data Management, integración), dirección, clave, granularidad, ámbito de compañía, volumen, frecuencia, seguridad y compatibilidad requerida. Identifica si existe una entidad estándar extensible adecuada.

## Implementación

- Extiende la entidad estándar cuando el punto de extensión lo soporte; evita duplicarla o modificarla por overlay.
- Añade campos y mapeos coherentes con tablas, EDTs, relaciones y semántica del contrato.
- Usa CoC o eventos solo sobre métodos/extension points soportados; no inventes hooks.
- Valida valores en el límite adecuado y entrega errores útiles al consumidor.
- Considera claves naturales, upsert, duplicados, idempotencia, orden de entidades, staging y comportamiento multi-compañía.
- No expongas datos sensibles ni campos internos sin justificación y permisos.

## Verificación

Compila y sincroniza metadata si se requiere; valida publicación, lectura/escritura, filtros, permisos, compañía y errores con datos representativos. Revisa compatibilidad de consumidores existentes y documenta cualquier cambio de contrato.

## Reglas aprendidas: entidad custom sobre tabla custom

- Ubicacion: los objetos se crean en el modelo, en K:\AosService\PackagesLocalDirectory\<MODELO>\<MODELO>\. El modelo casi siempre ya esta ligado al proyecto; no crear en source\repos. Verifica el tamano del archivo en K: (0 bytes = no se escribio).
- Nomenclatura: entidad = <TablaCustom>Entity; staging = <TablaCustom>Staging; privilegios = <TablaCustom>EntityMaintain y <TablaCustom>EntityView; formulario y MenuItem display = <TablaCustom>.
- Flujo: el asistente crea entidad y staging; se cambia el datasource a la tabla custom, se agregan campos y llave, y se regenera el staging. Con CustTable, dejar solo AccountNum al inicio.
- Habilitar siempre DataManagementEnabled=Yes e IsPublic=Yes (data management y API).
- FormRef: agregar el formulario custom solo despues de validar que existe en AxForm; si no existe, da error de compilacion.
- Sin ConfigurationKey cuando la tabla custom no lo tiene.

- Label propio: toda tabla, staging y entidad custom lleva su propio label en el archivo del modelo (es-MX y en-US), nunca el estandar del asistente (ej. @SYS11307). Usar el siguiente numero libre y un label distinto para la entidad y para el staging (ej. <Prefijo>_026 entidad, <Prefijo>_027 staging). Reemplazar el label por defecto que deja el asistente.

## Reglas aprendidas: extension de entidad estandar (CustCustomerV3)

- Carga masiva de clientes: Customers V3 (CustCustomerV3Entity) con staging CustCustomerV3Staging. Una fila con error no detiene el lote: lo resuelve DMF por fila, no requiere codigo.
- RFCNumber ya esta en la entidad (mapea a CustTable.Rfc_MX); no agregarlo. CustCustomerBaseEntity no expone Rfc_MX.
- Campo nuevo en entidad = prefijo GRW en Name y DataField apuntando al campo original (GRWSATPurpose_MX -> SATPurpose_MX), DataSource CustTable. El mismo campo y EDT en la extension de la staging.
- Estructura: AxDataEntityViewExtension\<Entidad>.<Modelo>.xml con AxDataEntityViewField i:type AxDataEntityViewMappedField.
- TaxRegimeCode_MX ya lo expone el estandar (CustCustomerV3Entity.ApplicationSuite_MX_Extension); decidir antes de duplicarlo con GRW.
- Las validaciones de negocio van en CustTable (CoC de validateWrite y validateField), no en la entidad: se ejecutan en DMF, Excel y OData. DataEntity.validateWrite no llama a la de la tabla. Verificar que "Run business validations" este activa para la entidad. Las entidades de clientes V2, V3 y base no usan skipDataSourceValidateWrite.
- Clase de mapeo solo si hay que defaultear o transformar; un campo con DataField no la necesita.
- Registrar en el .rnrproj: AxDataEntityViewExtension\<Nombre> (Link Data Entity Extensions\) y AxTableExtension\<Nombre> para la staging.
- Estado: extensiones creadas en GRWCXC_99_CustFiscalInfo, sin compilar ni probar con una importacion DMF.
