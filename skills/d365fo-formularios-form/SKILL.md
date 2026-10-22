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
- En tabla propia, el método va dentro de la tabla. En tabla estándar, usa una extensión: `[ExtensionOf(tableStr(SalesTable))] final class SalesTable_Extension { display Name custName() {...} }`. El nombre de la clase es ilustrativo: la nomenclatura de cualquier extensión varía según el modelo (todos los modelos son distintos), así que usa la del modelo en el que trabajas (ver `d365fo-clases-class`).

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

## Reglas aprendidas: lookup con event handler

- Usar solo cuando el usuario pide explicitamente event handlers (ver regla en `d365fo-clases-class`). Caso tipico: convertir un campo de texto en lookup/dropdown con query propia, sin relacion de tabla, para no afectar otros formularios que usan el mismo datasource.
- Patron: clase `GRW<Formulario>_<CodigoModelo>_EventHandler` con metodos `public static void` y atributo `[FormControlEventHandler(formControlStr(<Formulario>, <Control>), FormControlEventType::Lookup)]`. El nombre del control es el de la extension del formulario (ej. `DirPartyTable_GRWTaxRegimeCode`), no el campo de la tabla.
- Cuerpo: `SysTableLookup::newParameters(tableNum(<Tabla>), sender)`, `Query` con `QueryBuildDataSource` y rangos, `addLookupfield(<campo clave>, true)` y campos descriptivos, `parmQuery`, `performFormLookup()`.
- **Cancelar el lookup estandar:** el segundo argumento del evento Lookup se convierte a `FormControlCancelableSuperEventArgs` (NO `FormControlCancelEventArgs`, que devuelve null) y se llama a `CancelSuperCall()` despues de `performFormLookup()`. Referencia validada por el usuario: `GRWInventParameters_Frm_EventHandler` (modelo GRWGDP_002_StatusClasification), metodo `GRWClasificaction8020_GRWClasification8020_OnLookup`.
- Metodo de apoyo compartido: se puede extraer la logica a un `private static` que reciba el control, el `FormControlCancelableSuperEventArgs` y el filtro; cada handler lo llama con su filtro (ej. `EInvoiceExtCodeType_MX::TaxRegime` o `::Purpose`). No validado en compilacion.
- El lookup solo ayuda a elegir: no valida el valor tecleado. La validacion va en la tabla o en el CoC correspondiente.
- Un handler cubre un solo formulario. Si el campo aparece en otro formulario del mismo datasource (ej. `DirPartyQuickCreateForm` frente al formulario completo del party), hace falta otro handler.
- Escribir el XML del AxClass en el modelo por el flujo de `d365fo-errores-encontrados` (CASO-002) y registrarlo en el `.rnrproj`.

## Aportes del merge (d365fo-formularios)

Sigue las reglas de .github/copilot-instructions.md.

### Primer paso obligatorio
Pregunta siempre al usuario en qué modelo deben crearse los objetos, aunque el proyecto ya tenga uno. La ruta base es `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\` (el modelo aparece dos veces). No asumas `GRWEstevez`.
Localiza el `.rnrproj` de la solución en curso y compara su `<Model>` con el modelo indicado. Si no coinciden, avisa al usuario y pide confirmación antes de crear nada.

### Referencia estándar
Para confirmar formularios, datasources y controles estándar, búscalos en `K:\AosService\PackagesLocalDirectory\ApplicationSuite\Foundation\AxForm\`. Los archivos son enormes (`SalesTable.xml` supera las 35 000 líneas): no los leas completos; usa `Select-String -Pattern "<DataField>Campo</DataField>"` y luego `Get-Content <ruta> | Select-Object -Skip N -First M`.
Objetos ya verificados para OVE_11 en el formulario `SalesTable`: datasource `SalesTable`; el campo `PurchOrderFormNum` tiene dos controles, `References_PurchOrderFormNumHeader` (vista de encabezado) y `References_PurchOrderFormNum` (vista de detalle). Ambos son `AxFormStringControl`. Confirma el padre de cada uno antes de usarlo en una extensión.

### Carpetas y archivos
| Objeto | Carpeta | Archivo |
|---|---|---|
| Extensión de formulario | `AxFormExtension` | `<FormularioEstandar>.<Modelo>.xml` |
| Formulario nuevo | `AxForm` | `GRW<Nombre>.xml` |
| Elemento de menú Display (abre un formulario) | `AxMenuItemDisplay` | `GRW<Nombre>.xml` |
| Elemento de menú Action (ejecuta una clase) | `AxMenuItemAction` | `GRW<Nombre>.xml` |
| Elemento de menú Output (reporte o impresión) | `AxMenuItemOutput` | `GRW<Nombre>.xml` |
| Extensión de menú | `AxMenuExtension` | `<MenuEstandar>.<Modelo>.xml` |

Los elementos de menú y sus extensiones se generan en este skill (ver sección "Menús"). La seguridad queda fuera: al terminar, entrega la lista de elementos de menú nuevos para que se procese con `d365fo-seguridad`, porque los privilegios referencian esos elementos.

### Reglas
1. Una extensión de formulario nunca modifica el formulario estándar; solo agrega controles, referencias a datasources y modificaciones de propiedades.
2. Los controles nuevos de una extensión se colocan en un `<Parent>` existente del formulario estándar (por ejemplo `UpperGroup`, `Grid`, `TabSetup`). Si no estás seguro del nombre del control padre, márcalo con ?? y pregunta al usuario; no lo inventes.
3. Para mostrar un campo de la tabla en el formulario, el control referencia `<DataField>` y `<DataSource>`. Si el campo es de una tabla extendida, el datasource ya existe en el formulario estándar.
4. Tipo de control según el campo: `AxFormStringControl` (string), `AxFormIntegerControl` (int), `AxFormRealControl` (real), `AxFormDateControl` (date), `AxFormCheckBoxControl` (enum `NoYes`), `AxFormComboBoxControl` (otros enums, con `<Items />`).
5. Nombre de control de dato: `<Tabla>_<Campo>` (ejemplo: `CustTable_GRWEnableProductCatalog`). Nombre de grupo nuevo: `GRW<Nombre>`.
6. Nombre del envoltorio de la extensión (`<AxFormExtensionControl><Name>`): único dentro de la extensión y descriptivo, con prefijo `GRW` (ejemplo: `GRWCustomerOrderControl`). No uses nombres autogenerados como `Copy0fytyh0f1`.
7. Captions, etiquetas y ayudas salen del archivo `GRW<Req>` (`@GRW<Req>:<LabelId>`, ver `d365fo-labels`). Nunca texto fijo.
8. Si el objeto ya existe, no lo recrees: léelo y complementa con `replace_string_in_file`. Verifica antes con `file_search` por nombre.
9. Un archivo por llamada de `create_file`; las llamadas independientes van en paralelo. Si falla con "Could not get text view from file path", escribe el archivo con PowerShell en UTF-8 sin BOM (`[IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding $false))`) y verifica después que no haya caracteres dañados. Si tampoco es posible, entrega el XML al usuario. La herramienta de lectura de archivos no accede a `K:`; lee el modelo con la terminal en bloques cortos.
10. Agrega al `.rnrproj` de la solución en curso cada objeto creado (formulario, extensión de formulario, elementos y extensiones de menú) y sus labels. Edita el `.rnrproj` con `replace_string_in_file`, dentro de un `<ItemGroup>`, sin duplicar entradas y sin la extensión `.xml`:
```xml
<Content Include="AxFormExtension\<Objeto>">
  <SubType>Content</SubType>
  <Name><Objeto></Name>
  <Link><CarpetaVirtual>\<Objeto></Link>
</Content>
```
    `<CarpetaVirtual>` es la carpeta del proyecto de Visual Studio, no la del modelo. Formato verificado en un `.rnrproj` real: `Classes\` para clases y `Label Files\` para labels; para otros tipos copia la de una entrada existente. Cambia `AxFormExtension` por la carpeta del objeto
11. Marca con ?? cualquier formulario, datasource, control o campo estándar de los que no estés seguro.
12. Al terminar, pide abrir el formulario en el diseñador de Visual Studio y compilar antes de darlo por terminado. Un error de formato en el XML impide abrir el objeto.

### Buenas prácticas obligatorias
Todo objeto generado debe cumplirlas antes de entregarse. Revísalas al terminar cada archivo.
Todo método X++ lleva además, dentro de su comentario `///`, la etiqueta `<remarks>Autor: Jorge Eduardo Vargas Rayas | Fecha: AAAA-MM-DD | Versión D365FO: 10.0.48</remarks>` (regla de .github/copilot-instructions.md). La fecha es la del día de generación. Aplica también a las plantillas de este skill aunque no la muestren.
1. **Nombres en inglés siempre:** formularios, controles, grupos, datasources, métodos y variables. Sin nombres en español ni mezclados. Solo los textos de etiquetas (`.label.txt`) van en es-MX y en-US.
2. **Convenciones de nombres:** PascalCase; prefijo `GRW` en formularios nuevos, grupos nuevos y envoltorios de extensión; nombres descriptivos, sin abreviaturas ambiguas ni errores de ortografía.
3. **Documentación:** el formulario nuevo lleva `Caption` con etiqueta; cada grupo nuevo lleva `Caption` con etiqueta; cada método que se agregue en el código del formulario lleva comentario `///` con `<summary>`, `<param>` y `<returns>` en inglés.
4. **Indentación correcta:** tabuladores en el XML como en las plantillas; 4 espacios por nivel en el código X++ de los métodos y llaves en línea propia.
5. **Patrones de diseño:** usa el patrón del formulario (`SimpleList`, `DetailsMaster`, etc.) y sus propiedades (`Pattern`, `PatternVersion`, `Style`) tal como en las plantillas. No mezcles estilos.
6. **Código limpio:** sin código comentado, sin controles sin usar, sin textos fijos (usa etiquetas).
7. **Validación final:** antes de entregar, confirma que todo control tiene su `DataSource` y `DataField` correctos, que los captions usan etiquetas, que no hay nombres en español y que el padre del control existe; indica el resultado en la tabla de salida.

### Plantillas (tomadas de objetos reales del modelo)

#### Extensión de formulario
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxFormExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V6">
    <Name><FormularioEstandar>.<Modelo></Name>
    <ControlModifications />
    <Controls>
        <AxFormExtensionControl xmlns="">
            <Name>GRW<NombreEnvoltorio></Name>
            <FormControl xmlns=""
                i:type="AxFormStringControl">
                <Name><Tabla>_GRW<Campo></Name>
                <Type>String</Type>
                <FormControlExtension
                    i:nil="true" />
                <DataField>GRW<Campo></DataField>
                <DataSource><Tabla></DataSource>
            </FormControl>
            <Parent><ControlPadre></Parent>
        </AxFormExtensionControl>
    </Controls>
    <DataSourceModifications />
    <DataSourceReferences />
    <DataSources />
    <Parts />
    <PropertyModifications />
</AxFormExtension>
```

Control de casilla (enum `NoYes`):
```xml
<FormControl xmlns=""
    i:type="AxFormCheckBoxControl">
    <Name><Tabla>_GRW<Campo></Name>
    <Type>CheckBox</Type>
    <FormControlExtension
        i:nil="true" />
    <DataField>GRW<Campo></DataField>
    <DataSource><Tabla></DataSource>
</FormControl>
```

Control de lista desplegable (otros enums):
```xml
<FormControl xmlns=""
    i:type="AxFormComboBoxControl">
    <Name><Tabla>_GRW<Campo></Name>
    <Type>ComboBox</Type>
    <FormControlExtension
        i:nil="true" />
    <DataField>GRW<Campo></DataField>
    <DataSource><Tabla></DataSource>
    <Items />
</FormControl>
```

Botón que ejecuta un elemento de menú dentro de una extensión de formulario (ejemplo real `LedgerJournalTransVendPaym.GRWVenegas`, botón en `Print_MenuButton`):
```xml
<AxFormExtensionControl xmlns="">
    <Name>GRW<NombreEnvoltorio></Name>
    <FormControl xmlns=""
        i:type="AxFormMenuFunctionButtonControl">
        <Name>GRW<ElementoDeMenu></Name>
        <Type>MenuFunctionButton</Type>
        <FormControlExtension
            i:nil="true" />
        <MenuItemName>GRW<ElementoDeMenu></MenuItemName>
        <MenuItemType>Action</MenuItemType>
    </FormControl>
    <Parent><ControlPadre></Parent>
</AxFormExtensionControl>
```
`<MenuItemType>` es `Action`, `Output` o `Display` según el elemento. El elemento de menú debe existir antes de referenciarlo.

Grupo nuevo con varios controles (el grupo también se coloca dentro de un `<Parent>`):
```xml
<AxFormExtensionControl xmlns="">
    <Name>GRW<NombreEnvoltorio></Name>
    <FormControl xmlns=""
        i:type="AxFormGroupControl">
        <Name>GRW<NombreGrupo></Name>
        <Type>Group</Type>
        <FormControlExtension
            i:nil="true" />
        <Controls>
            <AxFormControl xmlns=""
                i:type="AxFormCheckBoxControl">
                <Name><Tabla>_GRW<Campo></Name>
                <Type>CheckBox</Type>
                <FormControlExtension
                    i:nil="true" />
                <DataField>GRW<Campo></DataField>
                <DataSource><Tabla></DataSource>
            </AxFormControl>
        </Controls>
        <Caption>@GRW<Req>:<LabelId></Caption>
    </FormControl>
    <Parent><ControlPadre></Parent>
</AxFormExtensionControl>
```

#### Formulario nuevo (patrón SimpleList)
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxForm xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V6">
    <Name>GRW<Nombre></Name>
    <SourceCode>
        <Methods xmlns="">
            <Method>
                <Name>classDeclaration</Name>
                <Source><![CDATA[
[Form]
public class GRW<Nombre> extends FormRun
{
}
]]></Source>
            </Method>
        </Methods>
        <DataSources xmlns="" />
        <DataControls xmlns="" />
        <Members xmlns="" />
    </SourceCode>
    <DataSources>
        <AxFormDataSource xmlns="">
            <Name>GRW<Tabla></Name>
            <Table>GRW<Tabla></Table>
            <Fields>
                <AxFormDataSourceField>
                    <DataField><Campo></DataField>
                </AxFormDataSourceField>
            </Fields>
            <ReferencedDataSources />
            <InsertAtEnd>No</InsertAtEnd>
            <InsertIfEmpty>No</InsertIfEmpty>
            <DataSourceLinks />
            <DerivedDataSources />
        </AxFormDataSource>
    </DataSources>
    <Design>
        <Caption xmlns="">@GRW<Req>:<LabelId></Caption>
        <Pattern xmlns="">SimpleList</Pattern>
        <PatternVersion xmlns="">1.1</PatternVersion>
        <Style xmlns="">SimpleList</Style>
        <Controls xmlns="">
            <AxFormControl xmlns=""
                i:type="AxFormActionPaneControl">
                <Name>FormActionPaneControl1</Name>
                <Type>ActionPane</Type>
                <FormControlExtension
                    i:nil="true" />
                <Controls />
            </AxFormControl>
            <AxFormControl xmlns=""
                i:type="AxFormGroupControl">
                <Name>FormGroupControl1</Name>
                <Pattern>CustomAndQuickFilters</Pattern>
                <PatternVersion>1.1</PatternVersion>
                <Type>Group</Type>
                <WidthMode>SizeToAvailable</WidthMode>
                <FormControlExtension
                    i:nil="true" />
                <Controls>
                    <AxFormControl>
                        <Name>QuickFilterControl1</Name>
                        <FormControlExtension>
                            <Name>QuickFilterControl</Name>
                            <ExtensionComponents />
                            <ExtensionProperties>
                                <AxFormControlExtensionProperty>
                                    <Name>targetControlName</Name>
                                    <Type>String</Type>
                                    <Value>FormGridControl1</Value>
                                </AxFormControlExtensionProperty>
                                <AxFormControlExtensionProperty>
                                    <Name>placeholderText</Name>
                                    <Type>String</Type>
                                </AxFormControlExtensionProperty>
                                <AxFormControlExtensionProperty>
                                    <Name>defaultColumnName</Name>
                                    <Type>String</Type>
                                </AxFormControlExtensionProperty>
                            </ExtensionProperties>
                        </FormControlExtension>
                    </AxFormControl>
                </Controls>
                <ArrangeMethod>HorizontalLeft</ArrangeMethod>
                <FrameType>None</FrameType>
                <Style>CustomFilter</Style>
                <ViewEditMode>Edit</ViewEditMode>
            </AxFormControl>
            <AxFormControl xmlns=""
                i:type="AxFormGridControl">
                <Name>FormGridControl1</Name>
                <Type>Grid</Type>
                <FormControlExtension
                    i:nil="true" />
                <Controls>
                    <AxFormControl xmlns=""
                        i:type="AxFormStringControl">
                        <Name>GRW<Tabla>_<Campo></Name>
                        <Type>String</Type>
                        <FormControlExtension
                            i:nil="true" />
                        <DataField><Campo></DataField>
                        <DataSource>GRW<Tabla></DataSource>
                    </AxFormControl>
                </Controls>
                <DataSource>GRW<Tabla></DataSource>
                <Style>Tabular</Style>
            </AxFormControl>
        </Controls>
    </Design>
    <Parts />
</AxForm>
```
Propiedades útiles del datasource: `<AllowDelete>No</AllowDelete>`, `<AllowCreate>No</AllowCreate>`. Agrega un `AxFormDataSourceField` por cada campo de la tabla que se use, incluidos los de sistema que el diseñador agrega por defecto (`DataAreaId`, `Partition`, `RecId`, `TableId`).

#### Formulario nuevo (patrón Custom, con ActionPane y pestañas)
Para formularios maestro-detalle (cabecera con grupos y una pestaña con cuadrícula de líneas) usa como referencia estructural el formulario `GRWCalculationAndControlOfCosts` del modelo:
1. `<Design>` con `<Pattern>Custom</Pattern>`, `ShowNewButton`/`ShowDeleteButton` según el diseño.
2. `ActionPane` con `ActionPaneTab` y `ButtonGroup` que contienen `AxFormMenuFunctionButtonControl` (requieren elementos de menú existentes).
3. `Tab` con `TabPage` que contienen `Group` y `Grid`; los grupos llevan `Columns` y `Caption` con etiqueta.
4. Datasources encadenados con `<JoinSource>` y `<LinkType>InnerJoin</LinkType>` para cabecera y líneas.
5. Métodos de visualización (`display`) y de ciclo de vida del formulario (`init`) dentro de `<SourceCode>`: documentados con `///` y escritos en inglés.
Estos formularios son largos; genéralos por partes (estructura, datasources, controles) y pide al usuario revisar en el diseñador de Visual Studio. No copies los nombres con errores de ortografía de los ejemplos del modelo (por ejemplo `MinimunDTASetting`).

### Lógica en formularios estándar (clases de extensión)
Para agregar lógica a un formulario estándar no lo modifiques: crea una clase `final` con CoC. Patrones reales del modelo GRWVenegas:
1. Formulario: `[ExtensionOf(formStr(SalesTable))] final class GRW<Formulario>_Frm_Extension` (ejemplo `GRWSalesTable_Frm_Extension`, método `recalculateRetailPricesDiscounts` con `next`). Se accede al datasource con `this.dataSource('SalesTable')` y su registro con `fds.cursor()`.
2. Datasource: `[ExtensionOf(formDataSourceStr(SalesEditLines, SalesParmTable))] final class GRW<Formulario>_DS_Extension` (ejemplo `GRWSalesEditLines_DS_Extension`, método `active`).
3. Llama siempre a `next <metodo>(...)` y respeta la firma del método estándar.
4. La clase de extensión se agrega al `.rnrproj` en `Classes\`.
5. La validación de un campo de tabla va en la tabla (extensión de `validateWrite` o `validateField`), no en el formulario, para cubrir importaciones, OData y batch. Ejemplo real para OVE_11: `GRWSalesTableTbl_Extension` extiende `SalesTable.validateWrite` y busca otro `SalesTable` con el mismo `PurchOrderFormNum` y `CustAccount` y distinto `SalesId`.

### Menús

#### Reglas de menús
1. Todo formulario nuevo que el usuario deba abrir necesita un elemento de menú Display con el mismo nombre que el formulario. Toda clase que se ejecute desde un menú (controlador SysOperation, proceso) necesita un elemento Action; todo reporte o impresión, un elemento Output.
2. El elemento de menú apunta al objeto con `<Object>`, escrito sin espacios al inicio ni al final (en `GRWSalesPriceUpdate` del modelo hay un espacio sobrante; no lo repitas). En Display basta el nombre del formulario. En Action y Output se agrega `<ObjectType>Class</ObjectType>` y el objeto es la clase controladora (por ejemplo `GRWSendXMLFileToStorageController`).
3. `Label` siempre desde etiquetas `@GRW<Req>:<LabelId>`. Incluye siempre `<SubscriberAccessLevel><Read xmlns="">Allow</Read></SubscriberAccessLevel>` como en las plantillas.
4. La extensión de menú nunca modifica el menú estándar; solo agrega elementos dentro de un nodo `<Parent>` existente. Si no estás seguro del nombre del menú o del nodo padre, márcalo con ?? y pregunta al usuario.
5. Nodos padre conocidos del modelo, que puedes usar sin preguntar: en `AccountsReceivable`: `InquiriesAndReports`, `Customers`, `PeriodicProcesses`, `Setup`; en `SalesAndMarketing`: `Setup`, `PeriodicTasks`. Cualquier otro se confirma con el usuario.
6. En la extensión, `<MenuItemType>` se indica para Action y Output; para Display se omite. Para ordenar, usa `<PositionType>AfterItem</PositionType>` con `<PreviousSibling>`; si no importa el orden, omítelos.
7. Los submenús nuevos (`AxMenuElementSubMenu`) llevan nombre `GRW<Nombre>` y `Label` con etiqueta.
8. Aplican las mismas reglas de nombres en inglés, no recrear objetos existentes (complementa con `replace_string_in_file`), un archivo por llamada de `create_file` y agregar los objetos al `.rnrproj` (regla 10 de formularios).

#### Elemento de menú Display
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuItemDisplay xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <Object>GRW<Nombre></Object>
    <SubscriberAccessLevel>
        <Read xmlns="">Allow</Read>
    </SubscriberAccessLevel>
</AxMenuItemDisplay>
```

#### Elemento de menú Action
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuItemAction xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <Object>GRW<Nombre>Controller</Object>
    <ObjectType>Class</ObjectType>
    <SubscriberAccessLevel>
        <Read xmlns="">Allow</Read>
    </SubscriberAccessLevel>
</AxMenuItemAction>
```

#### Elemento de menú Output
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuItemOutput xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
    <Name>GRW<Nombre></Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <Object>GRW<Nombre>Controller</Object>
    <ObjectType>Class</ObjectType>
    <SubscriberAccessLevel>
        <Read xmlns="">Allow</Read>
    </SubscriberAccessLevel>
</AxMenuItemOutput>
```

#### Extensión de menú
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
    <Name><MenuEstandar>.<Modelo></Name>
    <Customizations />
    <Elements>
        <AxMenuExtensionElement xmlns="">
            <Parent><NodoPadre></Parent>
            <MenuElement xmlns=""
                i:type="AxMenuElementMenuItem">
                <Name>GRW<Nombre></Name>
                <MenuItemName>GRW<Nombre></MenuItemName>
            </MenuElement>
        </AxMenuExtensionElement>
    </Elements>
    <MenuElementModifications />
    <PropertyModifications />
</AxMenuExtension>
```
Para Action u Output agrega `<MenuItemType>Action</MenuItemType>` o `<MenuItemType>Output</MenuItemType>` después de `<MenuItemName>`.

Posición ordenada dentro del padre (agrega estas dos líneas después de `<Parent>`):
```xml
<PositionType>AfterItem</PositionType>
<PreviousSibling><ElementoAnterior></PreviousSibling>
```

Submenú nuevo con elementos:
```xml
<AxMenuExtensionElement xmlns="">
    <Parent><NodoPadre></Parent>
    <MenuElement xmlns=""
        i:type="AxMenuElementSubMenu">
        <Name>GRW<NombreSubmenu></Name>
        <Label>@GRW<Req>:<LabelId></Label>
        <Elements>
            <AxMenuElement xmlns=""
                i:type="AxMenuElementMenuItem">
                <Name>GRW<Nombre></Name>
                <MenuItemName>GRW<Nombre></MenuItemName>
                <MenuItemType>Output</MenuItemType>
            </AxMenuElement>
        </Elements>
    </MenuElement>
</AxMenuExtensionElement>
```
Varios elementos hacia el mismo padre pueden ir en `AxMenuExtensionElement` separados, un elemento por bloque, como en `SalesAndMarketing.GRWEstevez`.

#### Extensión de elemento de menú
Para cambiar una propiedad de un elemento de menú estándar (por ejemplo, redirigir un Output a otra clase) no lo modifiques: crea su extensión en `AxMenuItemOutputExtension`, `AxMenuItemActionExtension` o `AxMenuItemDisplayExtension`, con nombre `<ElementoEstandar>.<Modelo>`. Ejemplo real (`SalesConfirmationOriginal.GRWVenegas`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuItemOutputExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
    <Name><ElementoEstandar>.<Modelo></Name>
    <PropertyModifications>
        <AxPropertyModification xmlns="">
            <Name>Object</Name>
            <Value>GRW<Nombre>Controller</Value>
        </AxPropertyModification>
    </PropertyModifications>
</AxMenuItemOutputExtension>
```
El mismo patrón aplica a Action y Display cambiando la raíz del XML.

### Salida esperada
Al terminar entrega una tabla: Objeto | Tipo | Archivo | Estado (creado, complementado, ya existía, pendiente) | Etiquetas usadas | Control o menú padre. Agrega la lista de elementos de menú nuevos para el skill `d365fo-seguridad`.


## Reglas aprendidas: extension de formulario con boton (DDF_65_05)
- Boton en el panel de acciones de un form estandar: AxFormExtensionControl con FormControl i:type="AxFormMenuFunctionButtonControl" (Name, Type=MenuFunctionButton, FormControlExtension nil, DataSource, MenuItemName) y <Parent> = grupo de botones real.
- Verificar el nombre del grupo en el XML estandar antes de usarlo: Select-String -Path K:\AosService\PackagesLocalDirectory\ApplicationSuite\Foundation\AxForm\<Form>.xml -Pattern "<Name>\w*(Invoice|Setup)\w*</Name>".
- CustTable, pesta�a Factura (aptabInvoice), seccion Configurar = btngrpInvoiceSetup. Ejemplo: CustTable.GRW_65_05_TaxAddendums.
- Plantilla SimpleList verificada en este ambiente: GRWEstevez\AxForm\GRWMinimumDTASetup (los modelos GRWGDP_002 citados arriba no existen en este ambiente).
- Si el form se abre desde un registro (p.ej. cliente), definir si debe filtrar por el registro llamador (args.record / dynalink); en DDF_65_05 quedo como pregunta abierta.
