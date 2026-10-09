---
name: d365fo-formularios-form
description: "Diseña, extiende y depura formularios de Microsoft Dynamics 365 Finance & Operations usando extensiones y patrones de UI soportados. Úsalo para controles, datasource, eventos, acciones, validaciones y presentación."
argument-hint: "Describe el formulario, el usuario/rol, la acción y el resultado esperado"
---

# D365 F&O — Formularios

## Entregable obligatorio: archivo .txt (prioridad 09)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `09_d365fo-formularios-form_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, formularios/controles/datasources y patrón aplicado, cambios, pruebas de UI realizadas y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Implementa cambios de UI sin trasladar reglas de negocio al control cuando pertenecen a una tabla o servicio.

## Investiga

Ubica formulario, datasources, controles, extensiones existentes, menú/entry point, seguridad y lógica invocada. Confirma si la regla es visual o una invariante de negocio.

## Implementa

- Usa form extensions y eventos soportados; evita overlay.
- Mantén handlers pequeños y delega lógica de negocio.
- Respeta datasource, cursor, `forUpdate`, validación y ciclo de vida del formulario.
- Controla estados vacíos, carga, error, éxito, selección y acciones repetidas.
- Asegura que mensajes sean accionables y que el usuario no pueda eludir validación mediante otra ruta.
- Verifica permisos y no expongas datos que el rol no debe ver.

## Pruebas

Prueba el flujo UI completo con roles/datos representativos, estados de validación y regresión relacionada. Ejecuta automatización de UI solo si el entorno la soporta. Reporta qué se probó visual y funcionalmente; no declares pruebas de navegador si no se realizaron.

## Patrón SimpleList: estructura XML de referencia (AxForm)

Fuente: formularios `GRWParetoClasification` y `GRWParetoClasificationAdm` del modelo `GRWGDP_002_StatusClasification` (ruta `...\GRWGDP_002_StatusClasification\AxForm\`). Es el patrón habitual para catálogos y listas simples. Respeta esta estructura al generar formularios nuevos y guarda el XML en UTF-8 con BOM (ver skill `d365fo-tablas-tables`, sección de codificación).

### Esqueleto del archivo

```
<AxForm xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V6">
  <Name>                      nombre del formulario (igual que el archivo)
  <SourceCode>                (hijos con xmlns="")
    <Methods>                 classDeclaration y métodos del form
    <DataSources>             métodos/campos del datasource (override de validateWrite, modified, etc.)
    <DataControls />  <Members />
  <DataSources>               definición de datasources (AxFormDataSource)
  <Design>                    patrón y controles
  <Parts />
```

Orden fijo de nodos raíz: `Name`, `SourceCode`, `DataSources`, `Design`, `Parts`. Los hijos de `SourceCode`, `DataSources` y `Design` llevan `xmlns=""` en el nodo contenedor o en cada elemento, tal como en los ejemplos.

### SourceCode

- `classDeclaration` es obligatorio:
  ```
  [Form]
  public class <NombreForm> extends FormRun
  {
  }
  ```
- Cada método va en `<Method><Name>..</Name><Source><![CDATA[ ... ]]></Source></Method>`. El código X++ va siempre dentro de `CDATA`.
- Métodos del datasource: `SourceCode/DataSources/DataSource` con `<Name>` igual al datasource y `<Methods>` (por ejemplo `validateWrite`, con `this.cursor()`).
- Métodos de campo del datasource (por ejemplo `modified`): `DataSource/Fields/Field` con `<DataField>` y `<Methods>`; ahí se usa `this.datasource().cursor()`.
- Las reglas de negocio se delegan a métodos estáticos de la tabla (por ejemplo `isSubsidiaryCompany()`, `exceedsNewMaxAge()`); el form solo orquesta.

### DataSources (AxFormDataSource, xmlns="")

```
<AxFormDataSource xmlns="">
  <Name>MiTabla</Name>
  <Table>MiTabla</Table>
  <Fields>
    <AxFormDataSourceField><DataField>Campo</DataField></AxFormDataSourceField>
    ...  (todos los campos de la tabla, en orden alfabético, incluidos DataAreaId, Partition, RecId, TableId y campos de sistema)
  </Fields>
  <ReferencedDataSources />
  <InsertIfEmpty>No</InsertIfEmpty>
  <DataSourceLinks />
  <DerivedDataSources />
</AxFormDataSource>
```

- `<InsertIfEmpty>No</InsertIfEmpty>` en los ejemplos para que no se cree un registro vacío al abrir.
- Nombre del datasource = nombre de la tabla.

### Design con patrón SimpleList

```
<Design>
  <Caption xmlns="">@MODELO:ETIQUETA</Caption>
  <DataSource xmlns="">MiTabla</DataSource>
  <Pattern xmlns="">SimpleList</Pattern>
  <PatternVersion xmlns="">1.1</PatternVersion>
  <Style xmlns="">SimpleList</Style>
  <TitleDataSource xmlns="">MiTabla</TitleDataSource>   (opcional; solo en el primer ejemplo)
  <Controls xmlns=""> ... </Controls>
</Design>
```

Controles en este orden exacto (nombres estándar del patrón):

1. **ActionPane** (`i:type="AxFormActionPaneControl"`): `Name=FormActionPaneControl1`, `Type=ActionPane`, `FormControlExtension i:nil="true"`, `<Controls />`, `DataSource`.
2. **Grupo de filtros** (`i:type="AxFormGroupControl"`): `Name=FormGroupControl1`, `Pattern=CustomAndQuickFilters`, `PatternVersion=1.1`, `Type=Group`, `WidthMode=SizeToAvailable`, y dentro `QuickFilterControl1` con `FormControlExtension` de nombre `QuickFilterControl` y propiedades:
   - `targetControlName` = `FormGridControl1`
   - `placeholderText` (vacío)
   - `defaultColumnName` = `FormGridControl1_<CampoClave>` (la columna por la que se filtra de inicio)
   Cierra con `ArrangeMethod=HorizontalLeft`, `FrameType=None`, `Style=CustomFilter`, `ViewEditMode=Edit`.
3. **Grid** (`i:type="AxFormGridControl"`): `Name=FormGridControl1`, `Type=Grid`, `FormControlExtension i:nil="true"`, controles de columna, `DataGroup`, `DataSource`, `Style=Tabular`.

### Columnas del grid

- Nombre: `FormGridControl1_<Campo>`.
- Tipos según el campo: `AxFormStringControl` (`Type=String`) y `AxFormCheckBoxControl` (`Type=CheckBox`, para `NoYes`). Cada columna lleva `FormControlExtension i:nil="true"`, `DataField` y `DataSource`.
- Columnas informativas de solo lectura (precargadas por código): `<Enabled>No</Enabled>` antes de `<Type>`.
- `DataGroup`: `AutoBrowse` o `Grid` (en el formulario con campos propios se usó `Grid`). Debe existir o poder resolverse en la tabla.
- Para un catálogo simple de 2 columnas (clave y descripción) basta con esas 2 columnas.

### Reglas al generar formularios nuevos

- Copia este esqueleto, cambia nombres de form, datasource, tabla, `Caption` (etiqueta `@MODELO:ID`, nunca texto fijo) y columnas.
- El nombre de la columna por defecto del filtro debe existir como control del grid.
- Todos los campos del datasource deben existir en la tabla.
- El form necesita menú item (display) y privilegios; ver las skills de seguridad.
- Validaciones y precargas: `validateWrite` en el datasource y `modified` en el campo; mensajes con `checkFailed`/`warning`. Prefiere etiquetas en lugar de textos fijos (los ejemplos usan textos fijos en español, evítalo en código nuevo).
- Verifica que el XML cargue con `XmlDocument.Load` y que el archivo esté en UTF-8 con BOM.

## Campos display en formularios (relacionado con `d365fo-tablas-tables`)

Un campo display muestra un valor calculado o de otra tabla sin guardarlo en base de datos. Se hace en dos pasos: el método vive en la tabla (skill `d365fo-tablas-tables`) y el control se enlaza en el formulario (esta skill).

### Paso 1: método display en la tabla
- Debe declararse `display`, sin parámetros, y devolver un tipo compatible con el control (`Description`, `Name`, `str`, `int`, `real`).
- Usa `select firstOnly` y evita consultas pesadas, porque se ejecuta en cada refresco del grid. Si es costoso, cachea el resultado.
- En tabla propia, el método va dentro de la tabla. En tabla estándar, usa una extensión: `[ExtensionOf(tableStr(SalesTable))] final class SalesTable_Extension { display Name custName() {...} }`.

### Paso 2: control en el formulario (XML)
En el grid, un control String con `DataMethod` en lugar de `DataField`:

```
<AxFormControl xmlns="" i:type="AxFormStringControl">
  <Name>FormGridControl1_TaxRegimeDescription</Name>
  <AllowEdit>No</AllowEdit>
  <Type>String</Type>
  <FormControlExtension i:nil="true" />
  <DataMethod>taxRegimeDescription</DataMethod>
  <DataSource>GRWCustFiscalData</DataSource>
  <Label>@CXC99:CXC99_011</Label>
</AxFormControl>
```

- Usa `DataMethod` (no `DataField`) y `DataSource` = datasource que contiene el método.
- `AllowEdit=No` porque es calculado. Pon siempre `Label` con etiqueta, ya que no hay campo del que heredarla.
- Los métodos display NO se agregan a `AxFormDataSource/Fields`; solo se enlazan en el control.
- Ejemplo real: `GRWCustFiscalData` con `taxRegimeDescription()` y `cfdiPurposeDescription()`, que consultan `EInvoiceExtCodeTable_MX` filtrando por `CodeType`.

## Regla para crear formularios nuevos

Para crear un formulario nuevo, el usuario debe indicar qué patrón aplicar. Si no lo indica, pregúntalo y ofrece la lista de patrones aprendidos. No asumas uno.

### Patrones aprendidos
| Patrón | Uso | Referencia |
|---|---|---|
| SimpleList (1.1) | Catálogos y listas simples (el más usado) | `GRWParetoClasification`, `GRWParetoClasificationAdm`, `GRWCustFiscalData` |

Agrega aquí cada patrón nuevo que se aprenda.

### Entregables al crear un formulario nuevo
1. `AxForm\<Nombre>.xml` con el patrón indicado.
2. `AxMenuItemDisplay\<Nombre>.xml` (`Label`, `Object`).
3. Etiquetas nuevas en `es-MX` y `en-US` del archivo de etiquetas del modelo.
4. Registro en el `.rnrproj`: `<Content Include="AxForm\<Nombre>">` y `<Content Include="AxMenuItemDisplay\<Nombre>">`.
5. Privilegio de seguridad (skill de seguridad) si aplica.

### Notas operativas (PowerShell)
- No leas XML grandes con `Get-Content`; falla o se cancela. Usa `get_file`.
- Para escribir XML largo: crea el archivo con `create_file` en una ruta temporal y cópialo al modelo con `Copy-Item`. `create_file` directo sobre `K:\AosService\...` puede fallar con "Could not get text view".
- Para editar etiquetas con acentos usa `replace_string_in_file`, que respeta UTF-8.
- Evita comandos largos encadenados; se cancelan. Ejecuta pasos pequeños y verifica cada uno.
- Verifica que el archivo no quede vacío después de crearlo.
