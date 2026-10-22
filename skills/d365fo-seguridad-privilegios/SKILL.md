---
name: d365fo-seguridad-privilegios
description: "Diseña y revisa la seguridad de D365 F&O con roles, duties, privileges, entry points y permisos de datos, aplicando mínimo privilegio. Úsalo para habilitar acceso a formularios, reportes, entidades, servicios y procesos."
argument-hint: "Indica la operación que debe autorizarse, usuarios/roles y datos que deben protegerse"
---

# D365 F&O — Seguridad y privilegios

## Entregable obligatorio: archivo .txt (prioridad 11)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `11_d365fo-seguridad-privilegios_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, privilegios/duties/roles definidos con sus permisos (Leer/Actualizar/Crear/Eliminar), entry points cubiertos, pruebas de acceso y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Concede únicamente los permisos necesarios para una tarea de negocio identificada. Responde en español y comprueba tanto acceso permitido como denegado.

## Flujo

1. Identifica el entry point y la operación: menú, formulario, reporte, servicio, entidad u objeto ejecutable.
2. Determina qué rol/duty existente se ajusta y si corresponde crear un privilegio nuevo.
3. Incluye solo permisos requeridos y sigue la arquitectura de seguridad del proyecto.
4. Considera permisos de lectura/escritura, acceso de entidad/API, compañía y datos sensibles.
5. Verifica el acceso efectivo con los roles pertinentes; no confíes solo en que los metadatos compilan.

No otorgues System Administrator como workaround, no amplíes permisos globales sin necesidad y no des por protegida una API solo porque su formulario está restringido. Entrega artefactos de seguridad, alcance y pruebas de acceso positivo/negativo.

## Reglas aprendidas: privilegios de entidades

- Dos privilegios por entidad, con los nombres que propone el asistente: <Entidad>Maintain (Create, Read, Update, Delete, Correct) y <Entidad>View (Read), en AxSecurityPrivilege.
- Cada uno referencia la entidad en DataEntityPermissions.
- Crear en el modelo en K:, no en source\repos.

## Aportes del merge (d365fo-privilegios)

Sigue las reglas de .github/copilot-instructions.md.

### Primer paso obligatorio
Pregunta al usuario el nombre del modelo. La ruta base es `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\` (el modelo aparece dos veces). No asumas `GRWEstevez`.

### Carpetas y archivos
| Objeto | Carpeta | Archivo |
|---|---|---|
| Privilegio | `AxSecurityPrivilege` | `GRW<Nombre>View.xml` o `GRW<Nombre>Maintain.xml` |

### Reglas
1. Entrada: la lista de elementos de menú nuevos que entrega `d365fo-formularios` (nombre y tipo: Display, Action u Output). Si no hay lista, pídela.
2. Un privilegio por nivel de acceso, que puede agrupar varios elementos de menú relacionados (como `GRWCalculationAndControlOfCostsMaintain`). Sufijos de nombre:
   - `View`: consulta.
   - `Maintain`: mantenimiento.
3. Permisos según el modelo: Display `View` → solo `Read`; Display `Maintain` y Action → `Correct`, `Create`, `Delete`, `Read`, `Update`; Output `View` → los cinco permisos, como en `GRWPackagingLabelReportView`. Un Display y las Actions que ejecuta desde sus botones van en el mismo privilegio `Maintain`.
4. En `<EntryPoints>` cada elemento es un `AxSecurityEntryPointReference` con `<Name>` y `<ObjectName>` iguales al elemento de menú, `<ObjectType>` (`MenuItemDisplay`, `MenuItemAction` o `MenuItemOutput`) y `<Forms />`. Solo los Display llevan `AxSecurityEntryPointReferenceForm` con el nombre del formulario.
   Para entidades de datos usa `DataEntityPermissions` con `AxSecurityDataEntityPermission` (ver plantilla).
5. Nombre con prefijo `GRW`, PascalCase, en inglés (ejemplo: `GRWVendAS2TableMaintain`). `Label` desde etiquetas `@GRW<Req>:<LabelId>`; si faltan, genera primero las etiquetas con `d365fo-labels`. Etiqueta sugerida: "Ver <objeto>" / "Mantener <objeto>" / "Ejecutar <objeto>" (en inglés para en-US).
6. Si el objeto ya existe, no lo recrees: léelo y complementa con `replace_string_in_file`. Verifica antes con `file_search`.
7. Un archivo por llamada de `create_file`; las llamadas independientes van en paralelo. Si falla con "Could not get text view from file path", entrega el XML al usuario.
8. No agregues archivos al `.rnrproj`; lo hace el usuario.
9. No generes duties ni roles, ni los propongas; su asignación la hace el usuario.
10. Si no estás seguro de un elemento de menú o permiso, márcalo con ?? y pregunta.
11. Al terminar, pide abrir el privilegio en Visual Studio y compilar.

### Plantillas (tomadas de objetos reales del modelo)

#### Privilegio de lectura (Display)
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxSecurityPrivilege xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>View</Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <DataEntityPermissions />
    <DirectAccessPermissions />
    <EntryPoints>
        <AxSecurityEntryPointReference>
            <Name>GRW<Nombre></Name>
            <Grant>
                <Read>Allow</Read>
            </Grant>
            <ObjectName>GRW<Nombre></ObjectName>
            <ObjectType>MenuItemDisplay</ObjectType>
            <Forms>
                <AxSecurityEntryPointReferenceForm>
                    <Name>GRW<Nombre></Name>
                    <Controls />
                    <DataSources />
                </AxSecurityEntryPointReferenceForm>
            </Forms>
        </AxSecurityEntryPointReference>
    </EntryPoints>
    <FormControlOverrides />
</AxSecurityPrivilege>
```

#### Privilegio de mantenimiento (Display con Actions)
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxSecurityPrivilege xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Nombre>Maintain</Name>
    <Label>@GRW<Req>:<LabelId></Label>
    <DataEntityPermissions />
    <DirectAccessPermissions />
    <EntryPoints>
        <AxSecurityEntryPointReference>
            <Name>GRW<Nombre></Name>
            <Grant>
                <Correct>Allow</Correct>
                <Create>Allow</Create>
                <Delete>Allow</Delete>
                <Read>Allow</Read>
                <Update>Allow</Update>
            </Grant>
            <ObjectName>GRW<Nombre></ObjectName>
            <ObjectType>MenuItemDisplay</ObjectType>
            <Forms>
                <AxSecurityEntryPointReferenceForm>
                    <Name>GRW<Nombre></Name>
                    <Controls />
                    <DataSources />
                </AxSecurityEntryPointReferenceForm>
            </Forms>
        </AxSecurityEntryPointReference>
        <AxSecurityEntryPointReference>
            <Name>GRW<Accion></Name>
            <Grant>
                <Correct>Allow</Correct>
                <Create>Allow</Create>
                <Delete>Allow</Delete>
                <Read>Allow</Read>
                <Update>Allow</Update>
            </Grant>
            <ObjectName>GRW<Accion></ObjectName>
            <ObjectType>MenuItemAction</ObjectType>
            <Forms />
        </AxSecurityEntryPointReference>
    </EntryPoints>
    <FormControlOverrides />
</AxSecurityPrivilege>
```

#### Privilegio de reporte (Output)
Mismo esquema que el anterior, con un solo `AxSecurityEntryPointReference`, los cinco permisos, `<ObjectType>MenuItemOutput</ObjectType>` y `<Forms />` (ejemplo real: `GRWPackagingLabelReportView`).

#### Privilegio de entidad de datos
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxSecurityPrivilege xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name>GRW<Entidad>View</Name>
    <DataEntityPermissions>
        <AxSecurityDataEntityPermission>
            <Grant>
                <Read>Allow</Read>
            </Grant>
            <Name>GRW<Entidad></Name>
            <Fields />
            <Methods />
        </AxSecurityDataEntityPermission>
    </DataEntityPermissions>
    <DirectAccessPermissions />
    <EntryPoints />
    <FormControlOverrides />
</AxSecurityPrivilege>
```

### Salida esperada
Al final, la lista de privilegios creados para que el usuario los asigne a sus duties y roles.


### Matriz real de privilegios (verificada en GRWEstevez AxSecurityPrivilege, 38 privilegios)

| Objeto nuevo | Privilegio(s) | ObjectType / nodo | Permisos | Ejemplo real |
|---|---|---|---|---|
| Display (form) | `<Nombre>View` + `<Nombre>Maintain` | `MenuItemDisplay` | View: `Read`; Maintain: los 5 | `GRWCountriesOfOriginView/Maintain` |
| Display + Actions de sus botones | `Maintain` agrupa Display y Actions; `View` solo el Display | `MenuItemDisplay` + `MenuItemAction` | Maintain: 5; View: `Read` | `GRWCalculationAndControlOfCostsMaintain` |
| Action sola (proceso/batch) | Un privilegio con el nombre de la acción | `MenuItemAction` | 5, o `Read`+`Update` en procesos puntuales | `GRWReqPOUpdateOnDemand`, `GRWSendXMLFileToStorage` |
| Action + Display que abre | Un solo privilegio con ambos | `MenuItemAction` + `MenuItemDisplay` | 5 | `GRWCrateSOFromStorage`, `GRWLMATSalesOrderCreate` |
| Output (reporte) | `<Nombre>Report` o `<Nombre>View` (+ `Maintain` si se requiere) | `MenuItemOutput` | `Read` (típico) o 5 | `GRWCollectedtInvoiceCommissionReport`, `GRWProdOrderJournalReportView/Maintain` |
| Data entity | `<Entidad>View` + `<Entidad>Maintain` | `DataEntityPermissions` > `AxSecurityDataEntityPermission` (Name = entidad, Fields/Methods vacíos, EntryPoints vacío) | View: `Read`; Maintain: 5 | `GRWCountriesOfOriginEntityView/Maintain` |
| Entidad solo lectura | Solo `View` | `DataEntityPermissions` | `Read` | `GRWSalesTableEntityView`, `GRWInvoiceEntityView` |
| Tabla / clase / EDT / enum / extensión / label | Ninguno | n/a | n/a | n/a |

Reglas de decisión:
- Todo privilegio nace de un elemento de menú o de una entidad, nunca de tabla, clase o EDT.
- Display y entidades llevan dos niveles (View/Maintain); una acción puntual puede usar un solo privilegio.
- DirectAccessPermissions, FormControlOverrides y Forms van siempre vacíos.
- Si no es claro si un Output requiere Maintain, preguntar.


## Plantilla verificada de privilegio (DDF_65_05, tomada de GRWEstevez)
- Estructura completa: Name, Label, <DataEntityPermissions />, <DirectAccessPermissions />, EntryPoints/AxSecurityEntryPointReference (Name, Grant, ObjectName, ObjectType=MenuItemDisplay, Forms/AxSecurityEntryPointReferenceForm con Name del form, <Controls />, <DataSources />), <FormControlOverrides />.
- Maintain: Grant con Correct, Create, Delete, Read, Update = Allow. View: solo Read = Allow.
- Ejemplo: GRW_65_05_TaxAddendums\AxSecurityPrivilege\GRWCustAddendaMaintain / GRWCustAddendaView.
- Menu item display: raiz con xmlns="Microsoft.Dynamics.AX.Metadata.V1" y SubscriberAccessLevel/Read xmlns="" = Allow.
