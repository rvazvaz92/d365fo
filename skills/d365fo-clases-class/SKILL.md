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

## Aportes del merge (d365fo-clases)

Sigue las reglas de .github/copilot-instructions.md.

### Primer paso obligatorio
Pregunta siempre al usuario en qué modelo deben crearse las clases, aunque el proyecto ya tenga uno. La ruta es `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\AxClass\<NombreClase>.xml` (el modelo aparece dos veces). No asumas `GRWEstevez`.
Localiza el `.rnrproj` de la solución en curso y compara su `<Model>` con el modelo indicado. Si no coinciden, avisa al usuario y pide confirmación antes de crear nada.

### Referencia estándar
Para confirmar clases, tablas, métodos y firmas estándar, búscalos en `K:\AosService\PackagesLocalDirectory\ApplicationSuite\Foundation\` (`AxClass`, `AxTable`, `AxForm`). Los archivos son enormes: no los leas completos; usa `Select-String` para ubicar el método y luego `Get-Content <ruta> | Select-Object -Skip N -First M`.
Firmas verificadas en `SalesTable`: `public boolean validateWrite()` y `boolean validateField(FieldId _fieldId)`. Respeta la firma y la visibilidad al sobrescribir con CoC.
Otros modelos de referencia con clases reales: `K:\AosService\PackagesLocalDirectory\GRWEstevez\GRWEstevez\AxClass\` y `C:\Users\Admin0e2edd3f30\Music\GRWVenegas\AxClass\`.

### Tipos de clase y nomenclatura
| Tipo | Atributo | Nombre de clase |
|---|---|---|
| Extensión de tabla | `[ExtensionOf(tableStr(<Tabla>))]` | `GRW<Tabla>_Extension` (en el modelo también existen `_Tbl_Extension` y `_Table_Extension`; para clases nuevas usa `GRW<Tabla>_Extension`) |
| Extensión de clase | `[ExtensionOf(classStr(<Clase>))]` | `GRW<Clase>_Extension` |
| Extensión de formulario (clase del form) | `[ExtensionOf(formStr(<Form>))]` | `GRW<Form>_Form_Extension` |
| Extensión de datasource | `[ExtensionOf(formDataSourceStr(<Form>, <DS>))]` | `GRW<Form>Form_<DS>DS_Extension` |
| Extensión de control | `[ExtensionOf(formControlStr(<Form>, <Control>))]` | `GRW<Form>_<Control>_Extension` |
| Manejador de eventos | `[FormControlEventHandler(...)]`, `[DataEventHandler(...)]` | `<Form>_<DS>_GRW<Nombre>_Handler` |
| Lógica reutilizable | ninguno | `GRW<Req><Nombre>` (por ejemplo `GRWOVE11CustomerOrderValidation`) |

### Reglas
1. Las extensiones son siempre `final`. Usa `internal final` si no deben verse fuera del modelo.
2. Chain of Command: llama a `next <metodo>(...)` en cada método sobrescrito, respetando visibilidad y firma (un método `protected` sigue `protected`).
3. Métodos nuevos dentro de extensiones llevan prefijo `grw` (ejemplo: `grwDisplayCarrierName`) para evitar colisiones.
4. Los manejadores de eventos son `static` y se usan solo cuando CoC no es posible (por ejemplo, eventos de control en formularios).
5. La lógica de negocio va en una clase `final` con métodos `static` (ejemplo: `GRWOVE11CustomerOrderValidation.hasDuplicate`). Las extensiones y manejadores solo la invocan.
6. Mensajes y textos van con etiquetas `@GRW<Req>:<LabelId>` del skill `d365fo-labels`. Nunca texto fijo en el código.
7. Documenta cada clase y método con comentarios `///` (`<summary>`, `<param>`, `<returns>`). Sin código comentado.
8. Los formularios se acceden con `this.formRun()` o `sender.formRun()`; los controles con `controlName(formControlStr(...))` y se verifica que no sean nulos antes de usarlos.
9. Si el objeto ya existe, no lo recrees: léelo y complementa con `replace_string_in_file`. Verifica antes con `file_search` por nombre.
10. Un archivo por llamada de `create_file`; las llamadas independientes van en paralelo. Si falla con "Could not get text view from file path", escribe el archivo con PowerShell en UTF-8 sin BOM (`[IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding $false))`) y verifica después que no haya caracteres dañados. Si tampoco es posible, entrega el XML al usuario. La herramienta de lectura de archivos no accede a `K:`; lee el modelo con la terminal en bloques cortos.
11. Agrega al `.rnrproj` de la solución en curso cada clase creada, sin duplicar entradas y sin la extensión `.xml`. Formato verificado en un `.rnrproj` real (la clase va en la carpeta virtual `Classes\`):
```xml
<Folder Include="Classes\" />
<Content Include="AxClass\<Clase>">
  <SubType>Content</SubType>
  <Name><Clase></Name>
  <Link>Classes\<Clase></Link>
</Content>
```
    Al terminar pide recargar el proyecto en Visual Studio.
12. Marca con ?? cualquier método, campo o tabla estándar de los que no estés seguro.
13. Validaciones: usa `checkFailed("@GRW<Req>:<LabelId>")` y asigna `ret = false`; no uses `throw error` ni `warning` para bloquear el guardado. Los modelos existentes usan `throw error` y `warning`: no los copies.
14. Al terminar, pide compilar en Visual Studio antes de darlo por terminado.

### Buenas prácticas obligatorias
Todo objeto generado debe cumplirlas antes de entregarse. Revísalas al terminar cada archivo.
Todo método X++ lleva además, dentro de su comentario `///`, la etiqueta `<remarks>Autor: Jorge Eduardo Vargas Rayas | Fecha: AAAA-MM-DD | Versión D365FO: 10.0.48</remarks>` (regla de .github/copilot-instructions.md). La fecha es la del día de generación. Aplica también a las plantillas de este skill aunque no la muestren.
1. **Nombres en inglés siempre:** clases, métodos, variables, parámetros, constantes y comentarios. Sin nombres en español ni mezclados. Solo los textos de etiquetas (`.label.txt`) van en es-MX y en-US.
2. **Convenciones de nombres X++:** clases y métodos estáticos en PascalCase o camelCase según el estándar de Microsoft (clases PascalCase, métodos y variables camelCase); parámetros con prefijo `_` (`_salesTable`); variables locales sin prefijo. Nombres descriptivos, sin abreviaturas ambiguas ni nombres de una letra (salvo contadores de bucle).
3. **Documentación completa:** cada clase y cada método llevan comentario `///` con `<summary>`, un `<param name = "...">` por parámetro y `<returns>` si devuelve valor. Las descripciones explican el propósito, no repiten el nombre. Sin comentarios vacíos (`///` sin texto).
4. **Indentación correcta:** 4 espacios por nivel dentro del código X++, llave de apertura y cierre en línea propia alineadas con la sentencia, una sentencia por línea y una línea en blanco entre bloques lógicos. En el XML del objeto, tabuladores como en las plantillas.
5. **Código limpio:** sin código comentado, sin variables ni `using` sin usar, sin números ni textos fijos (usa constantes, enums o etiquetas), sin lógica duplicada.
6. **Consultas:** `firstOnly` cuando se espera un solo registro, filtros por campos indexados y sin consultas dentro de bucles cuando pueda evitarse.
7. **Validación final:** antes de entregar, confirma que cada método está documentado, que no hay nombres en español y que la indentación es uniforme; indica el resultado en la tabla de salida.

### Plantillas (tomadas de clases reales del modelo)

#### Extensión de tabla
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Tabla>_Extension</Name>
    <SourceCode>
        <Declaration><![CDATA[
[ExtensionOf(tableStr(<Tabla>))]
final class GRW<Tabla>_Extension
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>grw<MetodoNuevo></Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <returns><Retorno></returns>
    display <EDT> grw<MetodoNuevo>()
    {
        return <Expresión>;
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Extensión de tabla con validación (patrón de OVE_11)
La regla de negocio va en una clase de lógica (`GRW<Req><Nombre>`, métodos `static`); la extensión de tabla solo la invoca. Las validaciones usan `checkFailed` con label y `ret = false`; no uses `throw error` ni `warning` para bloquear el guardado. Consulta con `firstOnly` y solo los campos necesarios. Ejemplo para `SalesTable.PurchOrderFormNum` (EDT `CustPurchaseOrder`, longitud 20):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRWSalesTable_Extension</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// Extension of <c>SalesTable</c> to validate the customer order.
/// </summary>
[ExtensionOf(tableStr(SalesTable))]
final class GRWSalesTable_Extension
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>validateWrite</Name>
                <Source><![CDATA[
    /// <summary>
    /// Validates that the customer order is not duplicated for the same customer.
    /// </summary>
    /// <returns>true if the record can be saved; otherwise, false.</returns>
    /// <remarks>Autor: <nombre> | Fecha: AAAA-MM-DD | Versión D365FO: 10.0.48</remarks>
    public boolean validateWrite()
    {
        boolean ret = next validateWrite();

        if (ret && GRWOVE11CustomerOrderValidation::hasDuplicate(this))
        {
            ret = checkFailed(strFmt("@GRWOVE_11:DuplicateCustomerOrderBlocked", this.PurchOrderFormNum, this.CustAccount));
        }

        return ret;
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```
Verifica que los parámetros de `strFmt` coincidan con los placeholders (`%1`, `%2`, `%3`) del label en ambos idiomas.

#### Manejador de delegado o evento de clase
Cuando no hay CoC posible, un delegado se atiende con `[SubscribesTo(classStr(<Clase>), delegateStr(<Clase>, <delegado>))]` en un método `static` (ejemplo real `GRWPrintMgtDocTypeHandler`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Handler</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// <Descripción>
/// </summary>
public class GRW<Nombre>Handler
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name><delegado></Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <param name = "_param"><Descripción></param>
    /// <param name = "_result">Resultado del evento.</param>
    [SubscribesTo(classStr(<Clase>), delegateStr(<Clase>, <delegado>))]
    public static void <delegado>(<Tipo> _param, EventHandlerResult _result)
    {
        <Lógica>
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Extensión de datasource de formulario
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Form>Form_<DS>DS_Extension</Name>
    <SourceCode>
        <Declaration><![CDATA[
[ExtensionOf(formDataSourceStr(<Form>, <DS>))]
final class GRW<Form>Form_<DS>DS_Extension
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>active</Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <returns>Valor devuelto por el método base.</returns>
    public int active()
    {
        int ret;

        ret = next active();

        <Lógica>

        return ret;
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Extensión de control de formulario
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Form>_<Control>_Extension</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// <Descripción>
/// </summary>
[ExtensionOf(formControlStr(<Form>, <Control>))]
final class GRW<Form>_<Control>_Extension
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name>clicked</Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    public void clicked()
    {
        FormButtonControl btn = any2Object(this) as FormButtonControl;

        <Lógica previa>

        next clicked();

        <Lógica posterior>
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Extensión de clase
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Clase>_Extension</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// <Descripción>
/// </summary>
[ExtensionOf(classStr(<Clase>))]
internal final class GRW<Clase>_Extension
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name><MetodoSobrescrito></Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <param name = "_param"><Descripción></param>
    protected void <MetodoSobrescrito>(<Tipo> _param)
    {
        next <MetodoSobrescrito>(_param);

        <Lógica>
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Manejador de eventos de control
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><Form>_<DS>_GRW<Nombre>_Handler</Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// <Descripción>
/// </summary>
final class <Form>_<DS>_GRW<Nombre>_Handler
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name><Control>_OnModified</Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <param name = "sender">Control que genera el evento.</param>
    /// <param name = "e">Argumentos del evento.</param>
    [FormControlEventHandler(formControlStr(<Form>, <Control>), FormControlEventType::Modified)]
    public static void <Control>_OnModified(FormControl sender, FormControlEventArgs e)
    {
        <Lógica>
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

#### Clase de lógica
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxClass xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Req><Nombre></Name>
    <SourceCode>
        <Declaration><![CDATA[
/// <summary>
/// <Descripción>
/// </summary>
final class GRW<Req><Nombre>
{
}
]]></Declaration>
        <Methods>
            <Method>
                <Name><metodo></Name>
                <Source><![CDATA[
    /// <summary>
    /// <Descripción>
    /// </summary>
    /// <param name = "_param"><Descripción></param>
    /// <returns><Retorno></returns>
    public static <Tipo> <metodo>(<Tipo> _param)
    {
        <Lógica>
    }

]]></Source>
            </Method>
        </Methods>
    </SourceCode>
</AxClass>
```

### Salida esperada
Al terminar entrega una tabla: Clase | Tipo | Archivo | Estado (creado, complementado, ya existía, pendiente) | Etiquetas usadas.
