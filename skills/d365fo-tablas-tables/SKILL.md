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
- Nomenclatura: el nombre de cualquier extension (tabla, clase, entidad, menu, formulario) varia segun el modelo, porque todos los modelos son distintos. Toma el patron del modelo en el que trabajas; no copies el de GRWCXC_99_CustFiscalInfo. Los ejemplos de esta skill son ilustrativos.
- Estructura de AxTableExtension: Name = <Tabla>.<Modelo>; campos con i:type AxTableFieldString o AxTableFieldEnum, ExtendedDataType o EnumType y Label.
- Labels con prefijo @<ARCHIVO>: (ej. @CXC99:CXC99_039) y presentes en en-US y es-MX. Sin prefijo se muestra el texto literal (ocurrio en GRWCustFiscalValidate y en campos de GRWCustFiscalData). No reutilizar el label del formulario para un campo.
- Antes de agregar un campo estandar a una entidad o staging, buscar en AxTableExtension y AxDataEntityViewExtension del estandar (ApplicationSuite_MX_Extension): TaxRegimeCode_MX ya esta expuesto en CustCustomerV3Entity y en su staging; agregarlo con GRW duplica el dato.
- Table.validateWrite y validateField se ejecutan en formularios, X++, OData, Excel y DMF; en DMF depende de "Run business validations" en Entity structure. Si validateField falla, validateWrite no se llama.
- Registrar cada extension en el .rnrproj: Content Include="AxTableExtension\<Nombre>" con Link Table Extensions\<Nombre>.
- En la staging de una entidad estandar, el campo lleva el mismo nombre y el mismo EDT que en la entidad.

## Reglas aprendidas: campos fiscales en DirPartyTable

- El formulario de creacion rapida de cliente (`DirPartyQuickCreateForm`) trabaja sobre `DirPartyTable`, no sobre `CustTable`: los datos propios del cliente no existen aun al capturar. Para capturarlos en ese formulario, agregarlos como campos de una extension de `DirPartyTable` y leerlos despues desde `CustTable`.
- Caso (GRWCXC_99_CustFiscalInfo): campos `GRWRfc_MX`, `GRWTaxRegimeCode` y `GRWCFDIPurposeCode` en `DirPartyTable`. `GRWRfc_MX` usa `IgnoreEDTRelation = Yes`.
- Decision del usuario: NO relacionar los campos de regimen y uso CFDI con su tabla de catalogo para no afectar otros formularios donde se use `DirPartyTable`; el dropdown se resuelve con un lookup por event handler (ver `d365fo-formularios-form`).
- Sin relacion no hay validacion automatica del valor: validar contra el catalogo en el CoC.
- Orden en el alta de cliente: `CustTable.insert` crea el party con `DirPartyTable::createNew(tipo, nombre)` y solo despues existe el cliente; ver `d365fo-clases-class` para validar y guardar.

## Aportes del merge (d365fo-tablas)

Sigue las reglas de .github/copilot-instructions.md.

### Primer paso obligatorio
Pregunta siempre al usuario en qué modelo deben crearse los objetos, aunque el proyecto ya tenga uno. La ruta base es `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\` (el modelo aparece dos veces). No asumas `GRWEstevez`.
Localiza el `.rnrproj` de la solución en curso y compara su `<Model>` con el modelo indicado. Si no coinciden, avisa al usuario y pide confirmación antes de crear nada.

### Referencia estándar
Para confirmar nombres de tablas, campos, EDT y enums estándar, búscalos en `K:\AosService\PackagesLocalDirectory\ApplicationSuite\Foundation\` (carpetas `AxTable`, `AxEdt`, `AxEnum`, `AxDataEntityView`). Los archivos son enormes (`SalesTable.xml` supera las 23 000 líneas): no los leas completos; usa `Select-String -Pattern "<Name>Campo</Name>" -Context 0,6` y lecturas con `Select-Object -Skip N -First M`.
Objetos ya verificados para OVE_11: tabla `SalesTable`; campo `PurchOrderFormNum` (string, EDT `CustPurchaseOrder`, longitud 20); campos `SalesId` y `CustAccount`; métodos `validateWrite`, `validateField` y `modifiedField`.
Otro modelo de referencia con entidades, staging y privilegios: `K:\AosService\PackagesLocalDirectory\GrowCFDIAddonLoad\Grow CFDI Addon Load\`.

### Carpetas y archivos
| Objeto | Carpeta | Archivo |
|---|---|---|
| Tabla nueva | `AxTable` | `GRW<Nombre>.xml` |
| Extensión de tabla | `AxTableExtension` | `<TablaEstandar>.<Modelo>.xml` |
| EDT nuevo | `AxEdt` | `GRW<Nombre>.xml` |
| Extensión de EDT | `AxEdtExtension` | `<EDTEstandar>.<Modelo>.xml` |
| Enum nuevo | `AxEnum` | `GRW<Nombre>.xml` |
| Extensión de enum | `AxEnumExtension` | `<EnumEstandar>.<Modelo>.xml` |

### Reglas
1. Objetos nuevos y campos nuevos en extensiones llevan prefijo `GRW` (ejemplo: `GRWEnableProductCatalog` en `CustTable.GRWEstevez`).
2. Una extensión nunca modifica el objeto estándar; solo agrega campos, índices, relaciones o modificaciones de propiedades.
3. Etiquetas y `HelpText` salen del archivo de labels del requerimiento (`@GRW<Req>:<LabelId>`, ver skill `d365fo-labels`). Si faltan, genera primero las etiquetas.
4. Todo campo (en tabla nueva o en extensión) debe llevar un EDT en `<ExtendedDataType>`, incluidos los campos enum (por ejemplo `NoYesId` con `<EnumType>NoYes</EnumType>`). Excepción: en campos enum cuyo enum no tiene EDT asociado (ejemplo real del modelo CFDI: `EInvoiceCFDIVersion_MX`) basta `<EnumType>`. Nunca dejes sin EDT un campo string, int, real o date. Procedimiento para elegirlo:
   1. Define las características del campo: tipo (string, int, real, date, enum…), longitud o decimales, y significado de negocio.
   2. Busca un EDT existente que coincida (estándar o `GRW*` del modelo) en tipo, tamaño y significado. Reutiliza el EDT del campo equivalente en la tabla estándar relacionada (por ejemplo, `CustAccount` para cuenta de cliente, `SalesId` para orden de venta).
   3. Si hay candidatos, elige el más específico y confirma con el usuario cuando haya duda.
   4. Si ninguno se adapta, crea un EDT nuevo `GRW<Nombre>` (o una extensión de EDT si solo cambia una propiedad), con la etiqueta del archivo `GRW<Req>`, antes de crear el campo.
   5. Marca con ⚠️ los EDT estándar cuyo nombre no puedas confirmar.
5. Si el objeto ya existe, no lo recrees: léelo y complementa con `replace_string_in_file`. Verifica antes con `file_search` por nombre.
6. Un archivo por llamada de `create_file`; las llamadas independientes van en paralelo. No uses comandos de PowerShell recursivos (se agota el tiempo de espera).
7. Si `create_file` falla con "Could not get text view from file path", escribe el archivo con PowerShell en UTF-8 sin BOM (`[IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding $false))`) y verifica después que no haya caracteres dañados. Si tampoco es posible, entrega el XML al usuario.
   La herramienta de lectura de archivos no accede a `K:`; para leer el modelo usa la terminal en bloques cortos (`(Get-Content <ruta> -TotalCount 60) -join "`n"`), porque los archivos grandes pueden hacer fallar la terminal.
8. Agrega al `.rnrproj` de la solución en curso cada objeto creado (tabla, extensión, EDT, enum, entidad, vista) y sus labels (ver skill `d365fo-labels`). Edita el `.rnrproj` con `replace_string_in_file`, dentro de un `<ItemGroup>`, sin duplicar entradas existentes y sin la extensión `.xml`:
```xml
<Content Include="AxTable\<Objeto>">
  <SubType>Content</SubType>
  <Name><Objeto></Name>
  <Link><CarpetaVirtual>\<Objeto></Link>
</Content>
```
   `<CarpetaVirtual>` es la carpeta del proyecto de Visual Studio, no la del modelo. Formato verificado en un `.rnrproj` real: `Classes\` para clases y `Label Files\` para labels (con su `<Folder Include="...\" />`); para otros tipos copia la de una entrada existente. Cambia `AxTable` por la carpeta del objeto
9. Si no estás seguro de un nombre de tabla, campo o EDT estándar, márcalo con ⚠️ y pregunta.
10. Al terminar, pide abrir el objeto en Visual Studio y compilar antes de darlo por terminado.

### Buenas prácticas obligatorias
Todo objeto generado debe cumplirlas antes de entregarse. Revísalas al terminar cada archivo.
Todo método X++ lleva además, dentro de su comentario `///`, la etiqueta `<remarks>Autor: Jorge Eduardo Vargas Rayas | Fecha: AAAA-MM-DD | Versión D365FO: 10.0.48</remarks>` (regla de .github/copilot-instructions.md). La fecha es la del día de generación. Aplica también a las plantillas de este skill aunque no la muestren.
1. **Nombres en inglés siempre:** tablas, campos, EDTs, enums, valores de enum, índices, relaciones y métodos. Sin nombres en español ni mezclados. Solo los textos de etiquetas (`.label.txt`) van en es-MX y en-US.
2. **Convenciones de nombres:** PascalCase para objetos, campos, índices y relaciones; prefijo `GRW` en objetos nuevos y en campos nuevos de extensiones; nombres descriptivos y sin abreviaturas ambiguas. Índices con sufijo `Idx` (ejemplo: `CustomerOrderIdx`).
3. **Documentación:** todo campo lleva `Label` y, cuando el usuario lo ve, `HelpText`, ambos desde etiquetas. Cada tabla lleva `Label`. Los métodos de tabla (`find`, `exist`, `validateWrite`, etc.) llevan comentario `///` con `<summary>`, `<param>` y `<returns>`, escrito en inglés.
4. **Indentación correcta:** tabuladores en el XML como en las plantillas; 4 espacios por nivel en el código X++ de los métodos, llaves en línea propia y una línea en blanco entre bloques lógicos.
5. **Estructura de tabla nueva:** incluye `TitleField1`, `PrimaryIndex`, un índice único (`AlternateKey`) cuando haya clave de negocio, relaciones hacia las tablas que referencia y los grupos de campos automáticos de la plantilla.
6. **Código limpio:** sin código comentado, sin textos fijos (usa etiquetas), sin variables sin usar. Para validaciones usa `checkFailed` en vez de `throw error`, salvo que el diseño pida abortar.
7. **Validación final:** antes de entregar, confirma que todo campo tiene EDT y etiqueta, que no hay nombres en español y que los métodos están documentados; indica el resultado en la tabla de salida.

### Plantillas (tomadas de objetos reales del modelo)

#### Enum nuevo
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEnum xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <UseEnumValue>No</UseEnumValue>
    <EnumValues>
        <AxEnumValue>
            <Name><Valor1></Name>
            <Label>@GRW<Req>:<LabelId1></Label>
        </AxEnumValue>
        <AxEnumValue>
            <Name><Valor2></Name>
            <Label>@GRW<Req>:<LabelId2></Label>
            <Value>1</Value>
        </AxEnumValue>
    </EnumValues>
    <IsExtensible>true</IsExtensible>
</AxEnum>
```
El primer valor no lleva `<Value>`; los siguientes llevan 1, 2, 3...

#### EDT nuevo (string)
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEdt xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns=""
    i:type="AxEdtString">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <ArrayElements />
    <Relations />
    <TableReferences />
    <StringSize>30</StringSize>
</AxEdt>
```
Para otros tipos cambia `i:type` (por ejemplo `AxEdtInt`, `AxEdtDate`) y ajusta las propiedades del tipo.

#### Extensión de EDT
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEdtExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><EDTEstandar>.<Modelo></Name>
    <ArrayElements />
    <PropertyModifications>
        <AxPropertyModification>
            <Name><Propiedad></Name>
            <Value><Valor></Value>
        </AxPropertyModification>
    </PropertyModifications>
</AxEdtExtension>
```

#### Extensión de tabla
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxTableExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><TablaEstandar>.<Modelo></Name>
    <FieldGroupExtensions />
    <FieldGroups />
    <FieldModifications />
    <Fields>
        <AxTableField xmlns=""
            i:type="AxTableFieldString">
            <Name>GRW<Campo></Name>
            <ExtendedDataType><EDT></ExtendedDataType>
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
            <Label>@GRW<Req>:<LabelId></Label>
        </AxTableField>
        <AxTableField xmlns=""
            i:type="AxTableFieldEnum">
            <Name>GRW<CampoEnum></Name>
            <ExtendedDataType><EDTdelEnum></ExtendedDataType>
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
            <Label>@GRW<Req>:<LabelId></Label>
            <EnumType><Enum></EnumType>
        </AxTableField>
    </Fields>
    <FullTextIndexes />
    <Indexes />
    <Mappings />
    <PropertyModifications />
    <RelationExtensions />
    <RelationModifications />
    <Relations />
</AxTableExtension>
```
Tipos de campo (`i:type`): `AxTableFieldString`, `AxTableFieldInt`, `AxTableFieldDate`, `AxTableFieldEnum`, entre otros. Todos los campos llevan `<ExtendedDataType>`. En campos enum, el EDT es el del enum (por ejemplo `NoYesId` para `NoYes`) y se mantiene `<EnumType>`.

Relación en extensión (clave foránea):
```xml
<AxTableRelation xmlns=""
    i:type="AxTableRelationForeignKey">
    <Name>GRW<RelacionNombre></Name>
    <Cardinality>ZeroMore</Cardinality>
    <RelatedTable><TablaRelacionada></RelatedTable>
    <RelatedTableCardinality>ZeroOne</RelatedTableCardinality>
    <RelationshipType>Association</RelationshipType>
    <Constraints>
        <AxTableRelationConstraint xmlns=""
            i:type="AxTableRelationConstraintField">
            <Name>GRW<Campo></Name>
            <Field>GRW<Campo></Field>
            <RelatedField><CampoRelacionado></RelatedField>
        </AxTableRelationConstraint>
    </Constraints>
    <Index><IndiceDeLaTablaRelacionada></Index>
</AxTableRelation>
```
Los índices nuevos van dentro de `<Indexes>` con `AxTableIndex`, `<Name>` y `<Fields>` de `AxTableIndexField` (`<DataField>`).

#### Tabla nueva
Estructura base (ejemplo real `GRWCountriesOfOrigin`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxTable xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre></Name>
    <SourceCode>
        <Declaration><![CDATA[
public class GRW<Nombre> extends common
{
}
]]></Declaration>
        <Methods />
    </SourceCode>
    <Label>@GRW<Req>:<LabelId></Label>
    <SubscriberAccessLevel>
        <Read>Allow</Read>
    </SubscriberAccessLevel>
    <TitleField1><Campo1></TitleField1>
    <TitleField2><Campo2></TitleField2>
    <AllowRowVersionChangeTracking>Yes</AllowRowVersionChangeTracking>
    <ModifiedDateTime>Yes</ModifiedDateTime>
    <PrimaryIndex><Indice></PrimaryIndex>
    <DeleteActions />
    <FieldGroups>
        <AxTableFieldGroup>
            <Name>AutoReport</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoLookup</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoIdentification</Name>
            <AutoPopulate>Yes</AutoPopulate>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoSummary</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoBrowse</Name>
            <Fields />
        </AxTableFieldGroup>
    </FieldGroups>
    <Fields>
        <AxTableField xmlns=""
            i:type="AxTableFieldString">
            <Name><Campo></Name>
            <ExtendedDataType><EDT></ExtendedDataType>
            <HelpText>@GRW<Req>:<LabelId></HelpText>
            <Label>@GRW<Req>:<LabelId></Label>
            <Mandatory>Yes</Mandatory>
        </AxTableField>
    </Fields>
    <FullTextIndexes />
    <Indexes>
        <AxTableIndex>
            <Name><Indice></Name>
            <AlternateKey>Yes</AlternateKey>
            <Fields>
                <AxTableIndexField>
                    <DataField><Campo></DataField>
                </AxTableIndexField>
            </Fields>
        </AxTableIndex>
    </Indexes>
    <Mappings />
    <Relations />
    <StateMachines />
</AxTable>
```
Métodos habituales en las tablas del modelo (`find`, `validateWrite`, `validateDelete`, `modifiedField`, `initValue`): decláralos dentro de `<Methods>` con el bloque `<Method><Name>…</Name><Source><![CDATA[…]]></Source></Method>` y comentarios `///`. Si la tabla tiene validaciones con `throw error`, prefiere `checkFailed` para no abortar la transacción, salvo que el diseño pida lo contrario.

### Referencia del modelo GRWEstevez
Antes de crear un objeto, verifica que no exista ya en `K:\AosService\PackagesLocalDirectory\GRWEstevez\GRWEstevez` y reutiliza lo existente.
1. **Tablas** (`AxTable`): `GRWMinimumDTASetup`, `GRWCountriesOfOrigin`, `GRWPackagingLabel`, además de tablas `Staging` y `Tmp`.
2. **Extensiones de tabla** (`AxTableExtension`, nombre `<Tabla>.GRWEstevez`): `SalesTable`, `SalesLine`, `CustTable`, entre otras.
3. **EDT** (`AxEdt`): `GRWObservation`, `GRWCountryOfOrigin`, `GRWCustom`, entre otros. Extensiones de EDT (`AxEdtExtension`): `PriceDiscAmount.GRWEstevez`, `UnitAmountCur.GRWEstevez`.
4. **Enums** (`AxEnum`): `GRWTrimesters`, `GRWProformaTypeReport`.
5. **Entidades** (`AxDataEntityView`): `GRWSalesTableEntity`, `GRWCountriesOfOriginEntity`. Extensiones de entidad (`AxDataEntityViewExtension`): `SalesOrderHeaderV4Entity.GRWEstevez`.
6. **Vistas** (`AxView`): `GRWCustomerView`, `GRWSalesTable_ProjRel`.

Hallazgos del modelo real:
- Los campos de extensión con EDT estándar suelen llevar `<IgnoreEDTRelation>Yes</IgnoreEDTRelation>`. Úsalo cuando el campo no deba heredar la relación del EDT.
- Algunos objetos usan `throw error` y comentarios `///` vacíos. No lo repitas: sigue las buenas prácticas de este skill.
- Evita literales con acentos en `#define`; se dañan al guardar. Usa etiquetas.
- Los IDs de archivos de labels del modelo son mixtos (`GRW_CDE_02`, `GRWINV05`, `GRWOVE_11`). Usa siempre el del requerimiento actual (ver skill `d365fo-labels`).

### Plantillas adicionales

#### Extensión de EDT
Ejemplo real (`UnitAmountCur.GRWEstevez`, cambia los decimales):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEdtExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><Edt>.GRWEstevez</Name>
    <ArrayElements />
    <PropertyModifications>
        <AxPropertyModification>
            <Name><Propiedad></Name>
            <Value><Valor></Value>
        </AxPropertyModification>
    </PropertyModifications>
</AxEdtExtension>
```

#### EDT nuevo de tipo string
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEdt xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns=""
    i:type="AxEdtString">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <ArrayElements />
    <Relations />
    <TableReferences />
    <StringSize><Longitud></StringSize>
</AxEdt>
```

#### Enum nuevo
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxEnum xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <UseEnumValue>No</UseEnumValue>
    <EnumValues>
        <AxEnumValue>
            <Name><Valor></Name>
            <Label>@GRW<Req>:<LabelId></Label>
        </AxEnumValue>
    </EnumValues>
    <IsExtensible>true</IsExtensible>
</AxEnum>
```

#### Extensión de entidad de datos
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxDataEntityViewExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><Entidad>.GRWEstevez</Name>
    <DataSources />
    <FieldGroupExtensions />
    <FieldGroups />
    <FieldModifications />
    <Fields>
        <AxDataEntityViewField xmlns=""
            i:type="AxDataEntityViewMappedField">
            <Name>GRW<Campo></Name>
            <DataField>GRW<Campo></DataField>
            <DataSource><TablaOrigen></DataSource>
        </AxDataEntityViewField>
    </Fields>
</AxDataEntityViewExtension>
```
Si el campo nuevo vive en una extensión de tabla, la entidad lo expone con `AxDataEntityViewMappedField` apuntando a la tabla origen. Si la entidad tiene tabla staging, agrega también el campo en la extensión de la tabla `...Staging`.

#### Entidad de datos nueva
Estructura real de `GRWCountriesOfOriginEntity` (los grupos de campos automáticos son los mismos de la tabla nueva):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxDataEntityView xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Entity</Name>
    <SourceCode>
        <Declaration><![CDATA[
public class GRW<Nombre>Entity extends common
{
}
]]></Declaration>
        <Methods />
    </SourceCode>
    <Label>@GRW<Req>:<LabelId></Label>
    <SubscriberAccessLevel>
        <Read>Allow</Read>
    </SubscriberAccessLevel>
    <DataManagementEnabled>Yes</DataManagementEnabled>
    <DataManagementStagingTable>GRW<Nombre>Staging</DataManagementStagingTable>
    <IsPublic>Yes</IsPublic>
    <PrimaryCompanyContext>DataAreaId</PrimaryCompanyContext>
    <PrimaryKey>EntityKey</PrimaryKey>
    <PublicCollectionName><Coleccion></PublicCollectionName>
    <PublicEntityName><Entidad></PublicEntityName>
    <SupportsSetBasedSqlOperations>Yes</SupportsSetBasedSqlOperations>
    <DeleteActions />
    <FieldGroups>
        <AxTableFieldGroup>
            <Name>AutoReport</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoLookup</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoIdentification</Name>
            <AutoPopulate>Yes</AutoPopulate>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoSummary</Name>
            <Fields />
        </AxTableFieldGroup>
        <AxTableFieldGroup>
            <Name>AutoBrowse</Name>
            <Fields />
        </AxTableFieldGroup>
    </FieldGroups>
    <Fields>
        <AxDataEntityViewField xmlns=""
            i:type="AxDataEntityViewMappedField">
            <Name><Campo></Name>
            <DataField><Campo></DataField>
            <DataSource>GRW<Tabla></DataSource>
        </AxDataEntityViewField>
    </Fields>
    <Keys>
        <AxDataEntityViewKey>
            <Name>EntityKey</Name>
            <Fields>
                <AxDataEntityViewKeyField>
                    <DataField><CampoClave></DataField>
                </AxDataEntityViewKeyField>
            </Fields>
        </AxDataEntityViewKey>
    </Keys>
    <Mappings />
    <Ranges />
    <Relations />
    <StateMachines />
    <ViewMetadata>
        <Name>Metadata</Name>
        <SourceCode>
            <Methods>
                <Method>
                    <Name>classDeclaration</Name>
                    <Source><![CDATA[
[Query]
public class Metadata extends QueryRun
{
}
]]></Source>
                </Method>
            </Methods>
        </SourceCode>
        <DataSources>
            <AxQuerySimpleRootDataSource>
                <Name>GRW<Tabla></Name>
                <DynamicFields>Yes</DynamicFields>
                <Table>GRW<Tabla></Table>
                <DataSources />
                <DerivedDataSources />
                <Fields />
                <Ranges />
                <GroupBy />
                <Having />
                <OrderBy />
            </AxQuerySimpleRootDataSource>
        </DataSources>
    </ViewMetadata>
</AxDataEntityView>
```
no copies la lista de campos del ejemplo.

#### Tablas staging
Las tablas `Staging` (`TableGroup` = `Staging`, `PrimaryIndex`/`ReplacementKey` = `StagingIdx`, campos de sistema `DefinitionGroup`, `ExecutionId`, `IsSelected`, `TransferStatus`) las genera Visual Studio al crear la entidad con **Data management** habilitado. No las escribas a mano. Si un campo nuevo se expone en una entidad, replícalo en la extensión de la tabla staging (`<Entidad>Staging.<Modelo>`), como hace `LedgerJournalEntityStaging.GrowCFDIAddonLoad`.

#### Vista (AxView)
Estructura real de `GRWCustomerView`: `SourceCode`, `SubscriberAccessLevel`, grupos de campos automáticos, `Fields` con `AxViewFieldBound` (`Name`, `DataField`, `DataSource`), `Indexes`, `Mappings`, `Relations` y `ViewMetadata` con `AxQuerySimpleRootDataSource` y los datasources embebidos (`AxQuerySimpleEmbeddedDataSource`) con su `AxQuerySimpleDataSourceRelation` (`Field`, `JoinDataSource`, `RelatedField`). Usa ese archivo como base.

#### Propiedades que aparecen en el modelo
- `AssetClassification` (por ejemplo `Customer Content`) aparece en campos estándar; no la inventes en campos nuevos.
- Mantén el prefijo `GRW` en mayúsculas en campos nuevos (el modelo CFDI tiene `GrwPayment` como excepción, no la repitas).

#### Validación sobre tabla estándar (patrón para esta solución)
Para validar un campo de una tabla estándar (por ejemplo `SalesTable`), no la modifiques: crea una extensión de clase con CoC sobre `validateWrite` o `validateField` y usa `checkFailed("@GRWOVE_11:<LabelId>")`. Verifica en el modelo si ya existe una extensión de clase para esa tabla antes de crear otra.

### Salida esperada
Al terminar entrega una tabla: Objeto | Tipo | Archivo | Estado (creado, complementado, ya existía, pendiente) | Etiquetas usadas.
