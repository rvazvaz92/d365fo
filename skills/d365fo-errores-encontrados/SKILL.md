---
name: d365fo-errores-encontrados
description: "Documenta errores reales encontrados y corregidos en soluciones D365 F&O/X++ como una base de conocimiento tipo wiki, con causa raíz, evidencia, solución, validación y prevención. Úsalo al depurar o cuando el usuario solicite registrar una lección técnica."
argument-hint: "Comparte el error, contexto, causa confirmada, solución y pruebas realizadas"
---

# D365 F&O — Wiki de errores y soluciones

## Entregable obligatorio: archivo .txt (prioridad 13)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `13_d365fo-errores-encontrados_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, las entradas de wiki registradas o actualizadas con el formato de esta skill y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Construye una base de conocimiento útil y verificable de problemas X++ y D365 F&O. No registres credenciales, datos personales ni secretos. No conviertas hipótesis no confirmadas en soluciones.

## Registro de cada caso

Incluye:

- ID/título descriptivo y fecha, si se conoce.
- Versión/plataforma, módulo, objeto y contexto mínimo reproducible.
- Mensaje/código exacto del error, eliminando datos sensibles.
- Síntoma, impacto, precondiciones y alcance.
- Causa raíz confirmada y evidencia; etiqueta como hipótesis si no se confirmó.
- Solución aplicada, alternativas descartadas y artefactos afectados.
- Validaciones ejecutadas y resultado real.
- Prevención, workaround temporal y riesgos/dependencias pendientes.
- Etiquetas de búsqueda (por ejemplo: compilación, CoC, SysOperation, entidad, batch, seguridad, rendimiento).

## Mantenimiento

Antes de agregar una entrada, busca duplicados y enlaza casos relacionados. Conserva historial de cambios cuando exista documentación previa; no sobrescribas conclusiones válidas silenciosamente. Usa el formato de documentación que ya tenga el repositorio. Si no existe, solicita o acuerda ubicación/formato antes de crear una wiki persistente. Nunca afirmes que un error fue solucionado sin validación documentada.

## Casos registrados

### CASO-001: XML de AxTable corrupto por codificación (ANSI vs UTF-8)
- **Modelo/objeto:** `GRWCXC_99_CustFiscalInfo`, tabla `GRWCustFiscalData`.
- **Síntoma:** el diseñador de Visual Studio mostraba solo el X++ suelto y las propiedades concatenadas.
- **Causa raíz (confirmada):** archivo guardado en Windows-1252 con `encoding="utf-8"` declarado; bytes de `é`, `á`, `ó` inválidos en UTF-8 (`HelpText`).
- **Solución:** reconvertir a UTF-8 con BOM sin cambiar contenido.
- **Validación:** `XmlDocument.Load` correcto y acentos legibles. No se probó en el diseñador.
- **Prevención:** guardar siempre en UTF-8 con BOM. Ver skill `d365fo-tablas-tables`.
- **Etiquetas:** codificación, metadata, AxTable.

### CASO-002: Creación y copia de archivos XML al modelo con PowerShell
- **Contexto:** crear `AxForm`, `AxMenuItemDisplay` y etiquetas en `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\`.
- **Síntoma:** `create_file` directo en `K:\AosService\...` falló con "Could not get text view from file path"; `run_command_in_terminal` se canceló ("A task was canceled") con comandos largos; el formulario quedó vacío en el modelo y solo existía en la carpeta temporal.
- **Causas (confirmadas por los resultados):** comando encadenado demasiado largo o con lecturas pesadas se cancela; `create_file` no puede abrir archivos del modelo fuera del proyecto; `Get-Content` sobre XML/proyectos grandes falló o se canceló.
- **Estado de los comandos probados:**

| Tarea | Método | Resultado |
|---|---|---|
| Crear XML nuevo en el modelo | `create_file` directo a `K:\...` | Falla |
| Crear XML nuevo en el modelo | `create_file` en `%TEMP%` + `Copy-Item -Force` al modelo | **Eficaz** |
| Comando largo con varias operaciones | `run_command_in_terminal` encadenado | Se cancela |
| Un paso pequeño por comando | `run_command_in_terminal` corto | **Eficaz** |
| Leer archivos | `get_file` | **Eficaz** (`Get-Content` falla en algunos) |
| Leer texto completo | `[IO.File]::ReadAllText(ruta,[Text.Encoding]::UTF8)` | **Eficaz** |
| Editar etiquetas con acentos | `replace_string_in_file` | **Eficaz** (conserva UTF-8) |
| Registrar en `.rnrproj` | `[IO.File]::ReadAllText` + `.Replace(ancla, ancla+nuevo)` + `WriteAllText` con `UTF8Encoding($true)` | **Eficaz** |
| Validar XML | `XmlDocument.Load` | **Eficaz** |
| Ubicar archivos | `file_search` | **Eficaz** |

- **Trampa de codificación:** los archivos creados con `create_file` en `%TEMP%` quedan en Windows-1252. Al anexarlos a otro archivo, léelos con `[Text.Encoding]::GetEncoding(1252)` y escribe el destino con `UTF8Encoding($false)`. Si se leen como UTF-8, los acentos quedan como `?` (ocurrió en la skill de formularios y se corrigió).
- **Procedimiento recomendado:** 1) `create_file` en `%TEMP%`; 2) `Copy-Item -Force` al modelo; 3) comprobar con `get_file` que no está vacío; 4) `XmlDocument.Load`; 5) registrar en el `.rnrproj`.
- **Validación:** el flujo anterior dejó `AxForm` y `AxMenuItemDisplay` válidos. No se compiló ni se abrió en Visual Studio.
- **Prevención:** no encadenar muchas operaciones; verificar cada paso; confirmar que el archivo del modelo no quedó vacío.
- **Etiquetas:** PowerShell, create_file, Copy-Item, codificación, rnrproj.
- **Relacionados:** CASO-001; skills `d365fo-formularios-form` y `d365fo-tablas-tables`.

### CASO-003: NullReferenceException por AxMenuExtension con estructura plana
- **Modelo/objeto:** `GRWCXC_99_CustFiscalInfo`, extension de menu de AccountsReceivable.
- **Sintoma:** `Abnormal termination ... System.NullReferenceException at AxMenuExtensionElement.get_Name() ... MetadataXRefSweeper`; `Failed to write runtime metadata to disk`; `Compilation failed`.
- **Causa raiz (confirmada):** los elementos tenian Name, ElementPosition, MenuItemName, MenuItemType y Parent directos dentro de AxMenuExtensionElement. El nombre va dentro de MenuElement (i:type AxMenuElementMenuItem) y el namespace raiz es Microsoft.Dynamics.AX.Metadata.V1.
- **Solucion:** reescribir con la estructura del estandar (ver skill `d365fo-userinterface`) y nombrar el archivo `<MenuBase>.<Modelo>.xml`, sin sufijo _Extension.
- **Validacion:** `run_build` termino con "Build successful" tras el cambio. El archivo original con solo GRWCustRFCCatalog tambien fallaba, por lo que el error no era del elemento nuevo.
- **Prevencion:** copiar la estructura de una extension real del estandar o de otro modelo antes de generar el XML.
- **Etiquetas:** compilacion, menu, AxMenuExtension.

### CASO-004: Proyecto sin objetos cargados y "A build is already in progress"
- **Sintoma:** Solution Explorer sin objetos; el log del proyecto decia `error : A build is already in progress`.
- **Contexto:** un `run_build` cancelado ("The operation was canceled") y un proceso `xppcAgent.17.0` vivo.
- **Causa:** NO confirmada. Hipotesis: la compilacion cancelada dejo el estado de build colgado. Los XML y el .rnrproj eran XML valido y los objetos referenciados existian en K:.
- **Workaround propuesto (sin validar):** cerrar Visual Studio, terminar `xppcAgent.17.0`, reabrir y recargar el proyecto.
- **Pendiente:** confirmar si el proyecto vuelve a cargar tras reabrir.
- **Etiquetas:** build, proyecto, xppcAgent.

### CASO-005: Escritura de XML por terminal en una linea (observacion)
- **Contexto:** `create_file`, `replace_string_in_file` y `multi_replace_string_in_file` fallaron con "Could not get text view" o "IWpfTextView" sobre archivos de K: y sobre el .rnrproj.
- **Observado:** `[IO.File]::WriteAllText(ruta, contenido)` en un comando corto funciono varias veces, pero fallo de forma intermitente con "Writing is not allowed after writer was completed" o con cancelaciones; reintentar el mismo comando, uno por llamada, lo resolvio.
- **Ojo:** una sola linea sin saltos compila, pero el estandar usa tabulaciones, CRLF y BOM; preferir ese formato. Tras escribir, verificar con `get_file` o `ReadAllText` y con `XmlDocument.Load`.
- **Preferido:** el flujo de CASO-002 (`create_file` en %TEMP% + `Copy-Item -Force`).
- **Etiquetas:** PowerShell, WriteAllText, rnrproj.
