---
name: d365fo-reportes-report
description: "Diseña y depura reportes D365 F&O según su fuente de datos y modo de ejecución, incluidos SSRS/RDP, Query-based y reportes simples. Revisa contratos, consultas, parámetros, alineación de datos y rendimiento."
argument-hint: "Indica el reporte, fuente de datos, tipo de ejecución, filtros y salida requerida"
---

# D365 F&O — Reportes

## Entregable obligatorio: archivo .txt (prioridad 10)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `10_d365fo-reportes-report_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, tipo de reporte, fuente de datos, parámetros, diseño/alineación, validación y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Determina primero el tipo de reporte y el patrón ya usado por el proyecto. No presupongas que todos los reportes deben usar RDP ni que los datos pueden consultarse sin respetar compañía y permisos.

## Diseño

- Confirma fuente de datos, granularidad, filtros, parámetros, orden, agrupaciones, formato y destino.
- Elige Query-based, RDP u otro patrón soportado según la complejidad y la arquitectura existente.
- Mantén contrato entre controller/contract, DP/dataset y diseño alineado.
- Filtra temprano, evita consultas por fila, limita campos y controla volumen.
- Considera multi-compañía, datos vacíos, totales, moneda/fecha y seguridad.
- No escondas errores de ejecución ni presentes datos parciales como resultado exitoso.

## Validación

Compila el reporte y valida parámetros, filtros, datos representativos, resultados vacíos, totales/alineación y tiempos razonables. Confirma salida en el destino requerido y reporta limitaciones de ambiente o datos.

## Deploy SSRS por PowerShell
Ver [deploy-ssrs-powershell.md](deploy-ssrs-powershell.md): DeployAllReportsToSSRS.ps1 con -ReportName, -Module o comodin.

## Aportes del merge (d365fo-reportes)

Sigue las reglas de .github/copilot-instructions.md.

### Primer paso obligatorio
Pregunta siempre al usuario en qué modelo deben crearse los objetos, aunque el proyecto ya tenga uno. La ruta base es `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\` (el modelo aparece dos veces). No asumas `GRWEstevez`.
Localiza el `.rnrproj` de la solución en curso y compara su `<Model>` con el modelo indicado. Si no coinciden, avisa al usuario y pide confirmación antes de crear nada.

### Referencia
Los reportes del modelo pesan entre 80 KB y 1,6 MB: no los leas completos. Usa `Select-String -Pattern "^\t<[A-Za-z]+"` para ver la estructura y `Get-Content <ruta> | Select-Object -Skip N -First M` para tramos cortos. Reportes de referencia en `K:\AosService\PackagesLocalDirectory\GRWEstevez\GRWEstevez\AxReport\` (`GRWCollectedInvoiceComission`, `GRWPackagingLabel`) y en `C:\Users\Admin0e2edd3f30\Music\GRWVenegas\AxReport\`. Verificado en `GRWCollectedInvoiceComission`: el `<Query>` es `SELECT * FROM <DP>.<Tabla>` y cada campo lleva `Alias` `<Tabla>.1.<Campo>`, `Caption`, `DataType` (por ejemplo `System.Double`), `DisplayWidth` y `UserDefined`.

### Objetos del reporte
| Objeto | Carpeta | Archivo | Skill |
|---|---|---|---|
| Tabla de datos del reporte (`InMemory`) | `AxTable` | `GRW<Nombre>Tmp.xml` | este skill (reglas de `d365fo-tablas`) |
| Contract | `AxClass` | `GRW<Nombre>Contract.xml` | este skill |
| Data Provider | `AxClass` | `GRW<Nombre>DP.xml` | este skill |
| Controller | `AxClass` | `GRW<Nombre>Controller.xml` | este skill |
| Reporte | `AxReport` | `GRW<Nombre>.xml` | este skill |
| Query (opcional) | `AxQuery` | `GRW<Nombre>Query.xml` | solo si el DDF lo pide; si no existe, pide al usuario un ejemplo |
| Menú Output | `AxMenuItemOutput` | `GRW<Nombre>.xml` | `d365fo-formularios` (apunta al Controller) |
| Privilegio | `AxSecurityPrivilege` | `GRW<Nombre>View.xml` | `d365fo-privilegios` |

### Reglas
1. Orden de generación: etiquetas (`d365fo-labels`) → tabla → Contract → DP → Controller → reporte → menú → privilegio.
2. Prefijo `GRW` y sufijos fijos: `Tmp`, `Contract`, `DP`, `Controller`. Nombres en inglés, PascalCase y sin errores de ortografía. No copies los errores de los ejemplos del modelo (`Commision`, `Comission`, `ComisionPercen`).
3. Tabla de datos: `<TableType>InMemory</TableType>`, sin índices, con las plantillas de campo de `d365fo-tablas`. Todo campo lleva EDT (regla EDT-first) y etiqueta. Un campo por columna del reporte.
4. Contract: `[DataContractAttribute]` con un método
5. Data Provider: `[SRSReportParameterAttribute(classStr(GRW<Nombre>Contract))]`, `final class ... extends SRSReportDataProviderBase`. Método `get<Tabla>` con `[SRSReportDataSetAttribute(tableStr(GRW<Nombre>Tmp))]` que devuelve la tabla. Método `processReport` que lee el Contract con `this.parmDataContract() as`, filtra con `Query`/`QueryRun` o `select` y llena la tabla con un método `insert<...>` separado.
6. Controller: `extends SrsReportRunController`, con `main` que asigna `parmArgs`, `parmReportName(ssrsReportStr(<Reporte>, <Diseño>))` y `startOperation()`.
7. Reporte: un dataset `ReportDataProvider` con `<Query>SELECT * FROM GRW<Nombre>DP.GRW<Nombre>Tmp</Query>`, un `AxReportDataSetField` por campo de la tabla, los parámetros de sistema `AX_*` y un parámetro por cada parámetro del Contract. Diseño `AxReportPrecisionDesign` con tablix de encabezado y detalle, y `PageHeader` con el título.
8. Etiquetas en el reporte: encabezados de columna como `=Labels!@GRW<Req>:<LabelId>`, títulos y prompts de parámetros con `@GRW<Req>:<LabelId>`. No uses texto fijo ni etiquetas `@SYS` si hay una etiqueta propia equivalente. Las que no puedas confirmar, márcalas con ??.
9. Coherencia obligatoria: el nombre del dataset, la tabla y el DP deben coincidir con el `<Query>`; cada parámetro del Contract debe existir en `<Parameters>` del dataset, en `ReportParameterBases`, en `ReportParameters` del RDL y en `ReportParametersLayout`. El parámetro del dataset que mapea al método `parm` lleva el nombre del `DataMemberAttribute`.
10. El campo `Text` del diseño es el RDL escapado como XML (`&lt;`, `&gt;`, `&amp;`). Escríbelo siempre escapado.
11. Genera el `AxReport` por partes si es largo (estructura, dataset, diseño) y pide revisarlo en el diseñador de Visual Studio. Un error de formato impide abrir el objeto. El diseño visual fino (anchos, estilos, grupos, totales) lo ajusta el usuario en Visual Studio.
12. Si el objeto ya existe, no lo recrees: léelo y complementa con `replace_string_in_file`. Verifica con `file_search`.
13. Un archivo por llamada de `create_file`; las llamadas independientes van en paralelo. Si falla con "Could not get text view from file path", escribe el archivo con PowerShell en UTF-8 sin BOM (`[IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding $false))`) y verifica después que no haya caracteres dañados. Si tampoco es posible, entrega el XML al usuario. La herramienta de lectura de archivos no accede a `K:`; lee el modelo con la terminal en bloques cortos.
    Agrega al `.rnrproj` de la solución en curso cada objeto creado (tabla, clases, reporte, menú y privilegio) y sus labels, sin duplicar entradas y sin la extensión `.xml`. Formato verificado en un `.rnrproj` real: las clases van en la carpeta virtual `Classes\` y los labels en `Label Files\`; para el resto copia el `<Link>` de una entrada existente. Al terminar pide recargar el proyecto en Visual Studio.
14. Al terminar, pide abrir el reporte en Visual Studio, compilar, generar el modelo y probar con y sin filtros.

### Buenas prácticas obligatorias
Todo método X++ lleva además, dentro de su comentario `///`, la etiqueta `<remarks>Autor: Jorge Eduardo Vargas Rayas | Fecha: AAAA-MM-DD | Versión D365FO: 10.0.48</remarks>` (regla de .github/copilot-instructions.md). La fecha es la del día de generación. Aplica también a las plantillas de este skill aunque no la muestren.
1. **Nombres en inglés** en clases,
2. **Documentación:** todo método de Contract, DP y Controller lleva `///` con `<summary>`, `<param>` y `<returns>` en inglés. Los ejemplos del modelo no los traen; los nuevos sí.
3. **Indentación:** 4 espacios por nivel en X++, llaves en línea propia, una línea en blanco entre bloques lógicos. Tabuladores en el XML.
4. **Código limpio:** sin código comentado, sin variables sin usar, sin textos fijos (no uses `"SI"`, `"NO"` ni etiquetas literales; usa etiquetas), sin códigos de moneda fijos (`"MXN"`): toma la moneda de un parámetro o de la contabilidad.
5. **Rendimiento:** el DP filtra en la consulta (rangos del `Query`) en vez de filtrar en el ciclo; evita llamadas repetidas a `find` con los mismos argumentos dentro del ciclo (guarda el resultado en una variable).
6. **Validación final:** confirma que la coherencia de la regla 9 se cumple, que todo campo tiene EDT y etiqueta, y que no hay nombres en español.

### Plantillas (tomadas de objetos reales del modelo)

#### Tabla de datos (InMemory)
Usa la plantilla de tabla nueva de `d365fo-tablas` con estas diferencias respecto a un ejemplo real:
```xml
<AxTable xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Tmp</Name>
    <SourceCode>
        <Declaration><![CDATA[
public class GRW<Nombre>Tmp extends common
{
}
]]></Declaration>
        <Methods />
    </SourceCode>
    <Label>@GRW<Req>:<LabelId></Label>
    <SubscriberAccessLevel>
        <Read>Allow</Read>
    </SubscriberAccessLevel>
    <TableType>InMemory</TableType>
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
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
            <Label>@GRW<Req>:<LabelId></Label>
        </AxTableField>
        <AxTableField xmlns=""
            i:type="AxTableFieldDate">
            <Name><CampoFecha></Name>
            <ExtendedDataType><EDT></ExtendedDataType>
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
        </AxTableField>
        <AxTableField xmlns=""
            i:type="AxTableFieldReal">
            <Name><CampoImporte></Name>
            <ExtendedDataType><EDT></ExtendedDataType>
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
        </AxTableField>
        <AxTableField xmlns=""
            i:type="AxTableFieldInt">
            <Name><CampoEntero></Name>
            <ExtendedDataType><EDT></ExtendedDataType>
            <IgnoreEDTRelation>Yes</IgnoreEDTRelation>
        </AxTableField>
    </Fields>
    <FullTextIndexes />
    <Indexes />
    <Mappings />
    <Relations />
    <StateMachines />
</AxTable>
```

#### Contract
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Contract</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// Contract with the parameters of the <Nombre> report.
/// </summary>
[DataContractAttribute]
class GRW<Nombre>Contract
{
    <EDT> <campo>;
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>parm<Campo></Name>
                <Source><![CDATA[
    /// <summary>
    /// Gets or sets the <campo> parameter.
    /// </summary>
    /// <param name = "_<campo>">The <campo> value.</param>
    /// <returns>The <campo> value.</returns>
    [DataMemberAttribute('<Campo>'), SysOperationLabelAttribute("@GRW<Req>:<LabelId>")]
    public <EDT> parm<Campo>(<EDT> _<campo> = <campo>)
    {
        <campo> = _<campo>;

        return <campo>;
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```
Con UIBuilder, la declaración lleva `[DataContractAttribute, SysOperationContractProcessingAttribute(classStr(GRW<Nombre>UIBuilder))]`.

#### Data Provider
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>DP</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// Data provider of the <Nombre> report.
/// </summary>
[SRSReportParameterAttribute(classStr(GRW<Nombre>Contract))]
final class GRW<Nombre>DP extends SRSReportDataProviderBase
{
    GRW<Nombre>Tmp reportTmp;
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>getGRW<Nombre>Tmp</Name>
                <Source><![CDATA[
    /// <summary>
    /// Gets the data set of the report.
    /// </summary>
    /// <returns>The report data buffer.</returns>
    [SRSReportDataSetAttribute(tableStr(GRW<Nombre>Tmp))]
    public GRW<Nombre>Tmp getGRW<Nombre>Tmp()
    {
        select reportTmp;

        return reportTmp;
    }

]]></Source>
            </Method>
            <Method>
                <Name>processReport</Name>
                <Source><![CDATA[
    /// <summary>
    /// Fills the report data buffer using the contract parameters.
    /// </summary>
    public void processReport()
    {
        GRW<Nombre>Contract contract = this.parmDataContract() as GRW<Nombre>Contract;
        Query               query    = new Query(queryStr(<QueryEstandarOGRW>));
        QueryRun            queryRun;

        if (contract.parm<Campo>())
        {
            query.dataSourceTable(tableNum(<Tabla>)).addRange(fieldNum(<Tabla>, <Campo>)).value(queryValue(contract.parm<Campo>()));
        }

        queryRun = new QueryRun(query);

        while (queryRun.next())
        {
            this.insertReportLine(queryRun.get(tableNum(<Tabla>)));
        }
    }

]]></Source>
            </Method>
            <Method>
                <Name>insertReportLine</Name>
                <Source><![CDATA[
    /// <summary>
    /// Inserts one line into the report data buffer.
    /// </summary>
    /// <param name = "_source">The source record.</param>
    public void insertReportLine(<Tabla> _source)
    {
        reportTmp.clear();
        reportTmp.<Campo> = _source.<Campo>;
        reportTmp.insert();
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Controller
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Controller</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// Controller of the <Nombre> report.
/// </summary>
class GRW<Nombre>Controller extends SrsReportRunController
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>main</Name>
                <Source><![CDATA[
    /// <summary>
    /// Runs the report.
    /// </summary>
    /// <param name = "_args">The caller arguments.</param>
    public static void main(Args _args)
    {
        GRW<Nombre>Controller controller = new GRW<Nombre>Controller();

        controller.parmArgs(_args);
        controller.parmReportName(ssrsReportStr(GRW<Nombre>, <Diseno>));
        controller.startOperation();
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```
`<Diseno>` es el nombre del diseño del reporte, en inglés (ejemplo: `Report`).

#### UIBuilder (solo si el diálogo necesita lookup o lógica)
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>UIBuilder</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// UI builder of the <Nombre> report dialog.
/// </summary>
class GRW<Nombre>UIBuilder extends SysOperationAutomaticUIBuilder
{
    private DialogField <campo>DialogField;
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>postBuild</Name>
                <Source><![CDATA[
    /// <summary>
    /// Binds the dialog field and overrides its lookup.
    /// </summary>
    public void postBuild()
    {
        super();

        <campo>DialogField = this.bindInfo().getDialogField(this.dataContractObject(), methodStr(GRW<Nombre>Contract, parm<Campo>));
        <campo>DialogField.registerOverrideMethod(methodStr(FormStringControl, lookup), methodStr(GRW<Nombre>UIBuilder, lookup<Campo>), this);
    }

]]></Source>
            </Method>
            <Method>
                <Name>lookup<Campo></Name>
                <Source><![CDATA[
    /// <summary>
    /// Shows the lookup of the <campo> field.
    /// </summary>
    /// <param name = "_formStringControl">The control that calls the lookup.</param>
    private void lookup<Campo>(FormStringControl _formStringControl)
    {
        Query                query = new Query();
        QueryBuildDataSource queryBuildDataSource;
        SysTableLookup       sysTableLookup;

        sysTableLookup       = SysTableLookup::newParameters(tableNum(<Tabla>), _formStringControl);
        queryBuildDataSource = query.addDataSource(tableNum(<Tabla>));

        sysTableLookup.addLookupfield(fieldNum(<Tabla>, <Campo>), true);
        sysTableLookup.parmQuery(query);
        sysTableLookup.performFormLookup();
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```
Para filtrar el lookup con una tabla relacionada (por ejemplo `DirPartyTable` con `HcmWorker`), agrega `queryBuildDataSource.addDataSource(...)` con `relations(false)`, `joinMode(JoinMode::InnerJoin)` y `addLink(...)`, como en `GRWCollectedInvoiceCommisionUIBuilder`. Quita `queryBuildDataSource` si no lo usas. No dejes comentarios de código.

#### Reporte (AxReport) — esqueleto
Partes obligatorias del XML, en este orden: `DataMethods`, `DataSets`, `DefaultParameterGroup`, `Designs`, `EmbeddedImages`.

Cabecera y dataset:
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxReport xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V2">
    <Name>GRW<Nombre></Name>
    <DataMethods />
    <DataSets>
        <AxReportDataSet xmlns="">
            <Name>GRW<Nombre>Tmp</Name>
            <DataSourceType>ReportDataProvider</DataSourceType>
            <DynamicFilters>false</DynamicFilters>
            <Query>SELECT * FROM GRW<Nombre>DP.GRW<Nombre>Tmp </Query>
            <FieldGroups />
            <Fields>
                <AxReportDataSetField>
                    <Name><Campo></Name>
                    <Alias>GRW<Nombre>Tmp.1.<Campo></Alias>
                    <Caption>@GRW<Req>:<LabelId></Caption>
                    <DataType><TipoNET></DataType>
                    <DisplayWidth>Auto</DisplayWidth>
                    <UserDefined>false</UserDefined>
                </AxReportDataSetField>
            </Fields>
            <Parameters>
                <AxReportDataSetParameter>
                    <Name>AX_PartitionKey</Name>
                    <Alias>AX_PartitionKey</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_PartitionKey</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name>AX_CompanyName</Name>
                    <Alias>AX_CompanyName</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_CompanyName</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name>AX_UserContext</Name>
                    <Alias>AX_UserContext</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_UserContext</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name>AX_RenderingCulture</Name>
                    <Alias>AX_RenderingCulture</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_RenderingCulture</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name>AX_ReportContext</Name>
                    <Alias>AX_ReportContext</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_ReportContext</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name>AX_RdpPreProcessedId</Name>
                    <Alias>AX_RdpPreProcessedId</Alias>
                    <DataType>System.String</DataType>
                    <Parameter>AX_RdpPreProcessedId</Parameter>
                </AxReportDataSetParameter>
                <AxReportDataSetParameter>
                    <Name><ParametroContract></Name>
                    <Alias><ParametroContract></Alias>
                    <DataType>System.String</DataType>
                    <Parameter><ParametroContract></Parameter>
                </AxReportDataSetParameter>
            </Parameters>
        </AxReportDataSet>
    </DataSets>
```
Tipos de `DataType` en los campos: `System.Double` (real), `System.DateTime` (fecha), `System.Int32` (entero); los string no llevan `DataType`.

Grupo de parámetros: los seis `AX_*` con `<UserVisibility>Hidden</UserVisibility>` (los de `AX_PartitionKey`, `AX_UserContext`, `AX_RenderingCulture`, `AX_ReportContext` y `AX_RdpPreProcessedId` también con `AllowBlank` y `Nullable` en `true`) y uno por cada parámetro del Contract:
```xml
    <DefaultParameterGroup>
        <Name xmlns="">Parameters</Name>
        <ReportParameterBases xmlns="">
            <AxReportParameterBase xmlns=""
                i:type="AxReportParameter">
                <Name>AX_CompanyName</Name>
                <UserVisibility>Hidden</UserVisibility>
                <DefaultValue />
                <Values />
            </AxReportParameterBase>
            <AxReportParameterBase xmlns=""
                i:type="AxReportParameter">
                <Name><ParametroContract></Name>
                <AllowBlank>true</AllowBlank>
                <Nullable>true</Nullable>
                <PromptString>@GRW<Req>:<LabelId></PromptString>
                <DefaultValue />
                <Values />
            </AxReportParameterBase>
        </ReportParameterBases>
    </DefaultParameterGroup>
```
(Incluye también `AX_PartitionKey`, `AX_UserContext`, `AX_RenderingCulture`, `AX_ReportContext` y `AX_RdpPreProcessedId` como en el ejemplo real.)

Diseño Precision:
```xml
    <Designs>
        <AxReportDesign xmlns=""
            i:type="AxReportPrecisionDesign">
            <Name><Diseno></Name>
            <Text>&lt;RDL escapado&gt;</Text>
            <DisableIndividualTransformation />
        </AxReportDesign>
    </Designs>
    <EmbeddedImages />
</AxReport>
```
El RDL (`Report` con namespace `http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition`) lleva, en este orden: `AutoRefresh`, `DataSources` (`AutoGen__ReportDataProvider`, `DataProvider` `AXREPORTDATAPROVIDER`), `DataSets` (con `QueryParameters` para los seis `AX_*` y cada parámetro del Contract, `CommandText` igual al `<Query>`, y un `Field` por columna con `DataField` = alias y `rd:TypeName`), `ReportSections` (`Body` con un `Tablix` de dos filas: encabezado con `=Labels!@GRW<Req>:<LabelId>`, negrita 6.5pt, fondo `LightGrey`; y detalle con `=Fields!<Campo>.Value`, 6.5pt, más `CustomProperties` `AXDataType`, `AXEDTFormat`, `AXEDTTextAlign` y `AXEDTDirection` apuntando a `<Tabla>.<Campo>`; `PageHeader` con el título centrado 12pt negrita; `PageFooter` con `=Globals!PageNumber`), `ReportParameters` (los `AX_*` con `Hidden` y los del Contract con `Prompt`), `ReportParametersLayout` (`GridLayoutDefinition` con una celda por parámetro), `Language`, `rd:ReportUnitType`, `rd:ExpressionDialog` y `rd:ReportID` (GUID nuevo). Tablix en horizontal para 10+ columnas: `PageWidth` 11in, `PageHeight` 8.5in, márgenes 0.15in.

Para armar el tablix y el RDL completos, parte siempre de un reporte real del modelo (por ejemplo `GRWCollectedInvoiceComission`) y reemplaza nombres, campos y etiquetas.

### Salida esperada
Tabla: Objeto | Tipo | Archivo | Estado (creado, complementado, ya existía, pendiente) | Etiquetas usadas. Al final entrega:
1. El elemento de menú Output necesario (nombre y Controller) para `d365fo-formularios`.
2. La lista de privilegios para `d365fo-privilegios`.
3. La lista de ?? pendientes de confirmar.
