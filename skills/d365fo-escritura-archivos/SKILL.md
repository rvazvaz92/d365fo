---
name: d365fo-escritura-archivos
description: Cómo crear o editar metadatos XML de D365FO (privilegios, menús, etiquetas) en PackagesLocalDirectory sin que se cuelgue el terminal ni fallen las herramientas de edición.
---

# Escritura de archivos D365FO

Complementa el CASO-002 y el CASO-005 de `d365fo-errores-encontrados`.

## Qué falla (no repetir)
- `create_file`, `replace_string_in_file` y `multi_replace_string_in_file` fallan con "Could not get text view" o "IWpfTextView" sobre archivos de `K:\AosService\PackagesLocalDirectory` que no están abiertos en la solución, y a veces sobre el `.rnrproj`.
- Comandos largos o encadenados en el terminal se cancelan (`A task was canceled`) o devuelven "Writing is not allowed after writer was completed".
- `Get-Content` sobre carpetas (por ejemplo `LabelResources\es-MX`) da "access denied".

## Qué funciona
1. Leer: `get_file`, `file_search`, `code_search`. Si `get_file` no encuentra un archivo fuera de la solución, usar `[IO.File]::ReadAllText(ruta,[Text.Encoding]::UTF8)`.
2. Etiquetas (`.label.txt`): `replace_string_in_file` sobre la última etiqueta, agregando las nuevas debajo. Conserva UTF-8.
3. XML nuevo (flujo preferido, validado en CASO-002):
   1. `create_file` en `%TEMP%`.
   2. `Copy-Item -Force` al modelo en `K:\...` y al repo.
   3. Verificar tamaño y contenido (no debe quedar en 0 bytes).
   4. Validar con `XmlDocument.Load`.
   5. Registrar en el `.rnrproj`.
4. Alternativa observada (menos estable): `[IO.File]::WriteAllText(ruta, contenido, (New-Object Text.UTF8Encoding($true)))` en un comando corto, uno por llamada. Reintentar la misma llamada si falla de forma intermitente.
5. Un paso pequeño por comando; verificar cada paso.

## Formato del XML
- Imitar el XML del estándar: tabulaciones, CRLF y BOM UTF-8. Una sola línea compila, pero Visual Studio puede reformatearla al guardar.
- Los archivos de `create_file` quedan en Windows-1252: al leerlos usar `[Text.Encoding]::GetEncoding(1252)` y escribir con `UTF8Encoding($false)` (o `$true` para XML con BOM). Ver CASO-002.
- Tras escribir, comprobar que no quedaron caracteres dañados.

## Privilegios
Por cada formulario custom, dos privilegios ligados a su `MenuItemDisplay`:
- `<Form>Maintain`: Create, Delete, Read, Update.
- `<Form>View`: Read.
- Cada uno con su etiqueta propia (`@CXC99:CXC99_0xx`) en `en-US` y `es-MX`.
- Se usa `AxSecurityEntryPointReference` con `Name`, `Grant`, `ObjectName` y `ObjectType` = `MenuItemDisplay`.
- Ver `d365fo-seguridad-privilegios`.

## Menús
- La extensión de menú tiene una estructura propia; la versión plana con `Name`, `ElementPosition` y `MenuItemName` directos en `AxMenuExtensionElement` rompe la compilación (CASO-003).
- La nomenclatura de cualquier extensión (menú, clase, tabla, entidad, formulario) varía según el modelo: confirma el patrón del modelo en el que trabajas.
- Ver `d365fo-userinterface`.

## Pendientes tras escribir
- Los archivos viven en `PackagesLocalDirectory`, no en el repo: copiarlos al proyecto o usar "Add existing item".
- Registrar cada objeto nuevo en el `.rnrproj`.
- Asignar los privilegios a un duty y a un rol.
- No compilar si el usuario pidió revisar antes.


## Reglas aprendidas: DDF_65_05 (flujo verificado)
- Antes de crear: comparar <Model> del .rnrproj con el modelo destino; inventariar el modelo con tamanos (detectar XML de 0 bytes).
- Flujo de escritura estable: create_file en <solucion>\staging\Ax<Tipo>\<Nombre>.xml -> robocopy staging <proyecto> /E -> robocopy staging <K:\modelo> /E -> validar tamano y [xml]. Ver CASO-011.
- El .rnrproj se edita solo por PowerShell. Formato: Content Include="Ax<Tipo>\<Nombre>" (sin .xml) + <Name> + <Link>; label.txt con DependentUpon. Ver CASO-010.
- Plantillas: tomar el XML mas pequeno del mismo tipo de un modelo existente; no generar XML de memoria. Ver CASO-013.
- Textos largos: create_file + Add-Content; nunca here-strings grandes por terminal. Ver CASO-012.
