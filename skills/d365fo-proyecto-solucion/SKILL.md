---
name: d365fo-proyecto-solucion
description: "Analiza la arquitectura y solución existente de un proyecto D365 F&O: modelos, paquetes, dependencias, artefactos, extensiones y convenciones. Úsalo para entender el estado actual antes de proponer cambios o estimar impacto."
argument-hint: "Indica el repositorio, modelo/paquete y la pregunta sobre la solución actual"
---

# D365 F&O — Análisis de proyecto y solución

## Entregable obligatorio: archivo .txt (prioridad 05)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `05_d365fo-proyecto-solucion_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, rutas inspeccionadas), qué se revisó y qué no pudo revisarse, arquitectura y flujo encontrados con rutas/nombres exactos, riesgos y preguntas abiertas.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Investiga cómo está construida la solución actual y presenta evidencia antes de proponer cambios. Responde en español.

## Inspección

- Identifica modelos, paquetes, referencias, estructura, nomenclatura y patrones existentes.
- Ubica artefactos relacionados con la funcionalidad (tablas, extensiones, clases, entidades, formularios, reportes, seguridad, pruebas).
- Sigue llamadas y dependencias relevantes; distingue objetos estándar de extensiones personalizadas.
- Evalúa puntos de extensión soportados, riesgos de upgrade, seguridad, rendimiento, compañía e integración.
- Registra brechas de compilación/pruebas solo si fueron observadas o ejecutadas.

## Entrega

Resume arquitectura relevante, flujo actual, objetos controladores, dependencias, convenciones y riesgos. Incluye rutas/nombres exactos como evidencia cuando el entorno permita inspeccionarlos. Propón el cambio mínimo compatible con la solución existente. No hagas cambios ni atribuyas problemas al código sin evidencia.

## Reglas aprendidas: documentar objetos del modelo

- Formato pedido por el usuario: `.txt` con tablas separadas por tabuladores, listas para pegar. Tabla 1: `Nombre<TAB>Tipo` con los objetos del modelo, SIN privilegios (ej. `EcoResProduct.GRWGDP_001_ProductDesc<TAB>Table Extension`). Tabla 2: `Etiqueta<TAB>Nombre<TAB>Nivel` solo para privilegios, con la etiqueta en espanol.
- Cómo obtenerlo: listar los archivos de cada carpeta `Ax*` del modelo en `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>` (solo las que tienen archivos); el nombre es el `BaseName`. Las etiquetas aparecen como un objeto unico por archivo de etiquetas (ej. `CXC99`), no uno por idioma.
- Tipos usados: Class Extension, Data Entity, Data Entity Extension, Enum, Form, Form Extension, Label File, Menu Extension, Menu Item Display, Table, Table Extension, Edt Extension, entre otros segun la carpeta.
- Etiqueta de privilegios: resolver `@<Archivo>:<Id>` en el `.label.txt` es-MX del modelo. Nivel deducido del nombre: `...Maintain` es Eliminacion (Create/Delete/Read/Update) y `...View` es Lectura; confirmar leyendo las concesiones del privilegio.
- Escribir el `.txt` en UTF-8 con BOM para conservar acentos. Guardarlo en `Entregables_Skills` del proyecto; si ya existe, anadir sufijo de fecha/hora.
- Ejemplo: `Documentacion_Objetos_GRWCXC_99_CustFiscalInfo.txt`: 20 objetos y 8 privilegios.

## Aportes del merge (d365fo-proyecto)

Sigue las reglas de .github/copilot-instructions.md.

### Cómo se obtiene la lista de objetos
El modelo es compartido por todos los proyectos, así que no se deduce escaneando las carpetas del modelo (además, los comandos recursivos sobre `K:` agotan el tiempo de espera). La lista viene de una de estas fuentes, en este orden:
1. **Tabla de entrega final** de `d365fo-requerimiento` o de otro skill de generación en la misma conversación: toma solo los objetos con estado "creado" o "complementado".
2. **Lista del usuario:** nombres de objeto con su tipo, o rutas de archivo (la carpeta `Ax<Tipo>` indica el tipo).
3. **Si no hay ninguna,** pídela. Nunca registres objetos por suposición.
Confirma la lista con el usuario antes de continuar. Los objetos que ya estaban en el modelo y solo se complementaron (por ejemplo una extensión existente) se registran solo si el usuario lo indica.

### Primer paso obligatorio
Pregunta al usuario:
1. La ruta completa del `.rnrproj` del requerimiento (un proyecto por requerimiento, un mismo modelo para todos). No asumas el proyecto.
2. El nombre del modelo y la lista de objetos a registrar (si viene de `d365fo-requerimiento`, ya los tienes).
3. Si el proyecto está cerrado en Visual Studio. Si está abierto, avisa que al guardar el archivo Visual Studio pedirá recargarlo y que es más seguro cerrar el proyecto o la solución antes.

### Reglas
1. Antes de editar, crea una copia de respaldo `<proyecto>.rnrproj.bak` junto al archivo. Si ya existe, usa `.bak2`, `.bak3`, etc. No sobrescribas respaldos.
2. Muestra al usuario las entradas exactas que vas a agregar y pide confirmación antes de editar.
3. Lee el `.rnrproj` completo antes de editar. No dupliques: si el objeto ya está registrado (mismo `Include`), omítelo e indícalo.
4. Solo agrega entradas dentro del `ItemGroup` que contiene los `<Content Include=...>`, y `<Folder Include=...>` dentro del `ItemGroup` de carpetas si la carpeta aún no existe. No modifiques `PropertyGroup`, `Import` ni otras entradas.
5. Mantén el orden y el formato del archivo: indentación de 2 espacios, entradas ordenadas alfabéticamente por `Include`, y las entradas de los `.label.txt` al final, como en el proyecto real.
6. Los objetos registrados deben existir ya en disco. Verifícalo con `file_search`; si no existe el archivo, no lo registres y repórtalo.
7. El `Include` no lleva extensión `.xml`. El nombre del objeto en `<Name>` es el mismo que el nombre del archivo sin `.xml`.
8. Si algún tipo de objeto no está en la tabla de abajo, no inventes la carpeta: márcalo con ?? y pide al usuario un ejemplo real del proyecto.
9. Al terminar, pide al usuario recargar la solución, compilar y revisar que los objetos aparezcan en el Solution Explorer.
10. No registres duties ni roles (no se generan).
11. Si `replace_string_in_file` no encuentra el `.rnrproj`, edítalo con un comando de PowerShell sin recursión: lee el texto con `[IO.File]::ReadAllText`, conserva el salto de línea y el BOM originales, inserta la entrada antes de la entrada alfabéticamente siguiente (ancla) y escribe con `[IO.File]::WriteAllText`. Luego valida que el archivo siga siendo XML con `[xml](Get-Content <ruta> -Raw)` y lista los `Include` para comprobar el resultado.

### Tipos y carpetas (tomados de un `.rnrproj` real)
| Tipo | `Include` | Carpeta en `Link` |
|---|---|---|
| Clase | `AxClass\<Nombre>` | `Classes\` |
| Tabla | `AxTable\<Nombre>` | `Tables\` |
| Extensión de tabla | `AxTableExtension\<Tabla>.<Modelo>` | `Table Extensions\` |
| EDT string | `AxEdt\<Nombre>` | `EDT Strings\` |
| EDT entero | `AxEdt\<Nombre>` | `EDT Integers\` |
| EDT real | `AxEdt\<Nombre>` | `EDT Reals\` |
| Formulario | `AxForm\<Nombre>` | `Forms\` |
| Extensión de formulario | `AxFormExtension\<Form>.<Modelo>` | `Form Extensions\` |
| Entidad de datos | `AxDataEntityView\<Nombre>` | `Data Entities\` |
| Extensión de entidad | `AxDataEntityViewExtension\<Entidad>.<Modelo>` | `Data Entity Extensions\` |
| Menú Display | `AxMenuItemDisplay\<Nombre>` | `Display Menu Items\` |
| Menú Action | `AxMenuItemAction\<Nombre>` | `Action Menu Items\` |
| Extensión de menú | `AxMenuExtension\<Menú>.<Modelo>` | `Menu Extensions\` |
| Privilegio | `AxSecurityPrivilege\<Nombre>` | `Security Privileges\` |
| Archivo de etiquetas | `AxLabelFile\<Id>_<idioma>` | `Label Files\` |

Sin ejemplo real en el proyecto (?? confirmar con el usuario antes de registrar): `AxMenuItemOutput`, `AxReport`, `AxQuery`, `AxEnum`, `AxEnumExtension`, `AxEdtExtension` y EDT de otros tipos (fecha, enum, etc.). Si el proyecto ya tiene una entrada de ese tipo, úsala como plantilla.

### Plantillas

#### Objeto (todos los tipos de la tabla)
```xml
    <Content Include="AxClass\GRW<Nombre>">
      <SubType>Content</SubType>
      <Name>GRW<Nombre></Name>
      <Link>Classes\GRW<Nombre></Link>
    </Content>
```
Cambia `Include` y `Link` según el tipo. Para extensiones, el nombre lleva punto: `ITMTable.GRWEstevez`.

#### Carpeta nueva (solo si no existe)
```xml
    <Folder Include="Classes\" />
```

#### Archivo de etiquetas (por idioma)
Entrada del descriptor:
```xml
    <Content Include="AxLabelFile\GRW<Req>_en-US">
      <SubType>Content</SubType>
      <Name>GRW<Req>_en-US</Name>
      <Link>Label Files\GRW<Req>_en-US</Link>
    </Content>
```
Entrada del texto, al final del `ItemGroup`:
```xml
    <Content Include="GRW<Req>.en-US.label.txt">
      <SubType>Content</SubType>
      <Name>GRW<Req>.en-US.label.txt</Name>
      <DependentUpon>AxLabelFile\GRW<Req>_en-US</DependentUpon>
    </Content>
```
Repite para `es-MX`.

### Salida esperada
1. Ruta del respaldo creado.
2. Tabla: Objeto | Tipo | Estado (agregado, ya registrado, no existe en disco, ?? sin plantilla).
3. Recordatorio: recargar la solución, compilar y revisar el Solution Explorer. Si el proyecto no abre, restaurar el `.bak`.
