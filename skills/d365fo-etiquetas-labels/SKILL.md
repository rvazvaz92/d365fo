---
name: d365fo-etiquetas-labels
description: "Crea, selecciona y asigna labels de Dynamics 365 F&O a campos, formularios, tablas, mensajes y otros metadatos. Revisa archivo de etiquetas, idioma, convenciones, reutilización y calidad de mensajes."
argument-hint: "Indica el texto, idioma, artefacto y contexto donde se mostrará la etiqueta"
---

# D365 F&O — Etiquetas

## Entregable obligatorio: archivo .txt (prioridad 12)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `12_d365fo-etiquetas-labels_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, tabla de etiquetas (ID, idioma, texto, objeto/propiedad donde se asigna), reutilizadas vs. nuevas y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Usa etiquetas localizables y convenciones del modelo para todo texto presentado al usuario.

## Procedimiento

- Busca si ya existe una etiqueta equivalente y reutilízala cuando su significado coincida.
- Si falta, crea una etiqueta con ID estable, conciso y conforme a las convenciones del proyecto.
- Añade traducciones en los idiomas requeridos por la solución cuando estén disponibles.
- Asigna la etiqueta al campo, EDT, formulario, control o mensaje correcto; valida que el tipo de propiedad admita label.
- Distingue caption, help text, error y texto interno de diagnóstico.
- No pongas texto visible hard-coded en X++ o metadata cuando deba ser localizable.

Verifica resolución de la etiqueta en los idiomas soportados y compila/sincroniza cuando sea necesario. No inventes IDs ya existentes; inspecciona el archivo/modelo de labels antes de elegir uno.

## Aportes del merge (d365fo-labels)

Sigue las reglas de .github/copilot-instructions.md.

Modelo (`<Modelo>`): SIEMPRE pregunta al usuario el modelo destino antes de crear cualquier archivo; no asumas ninguno ni reutilices el de una conversación anterior. Puedes sugerir el `<Model>` del `.rnrproj` en curso, pero espera confirmación. Si no responde, no crees nada.
Ruta del modelo: `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\`
Carpeta base: `AxLabelFile\`

ID del archivo de labels (`<ID>`):
1. Se construye como `GRW` + ID del requerimiento tal como aparece en el DDF, conservando el guion bajo y sin espacios. Ejemplo: `OVE_11` produce `GRWOVE_11`; `CXC_08` produce `GRWCXC_08`.
   Si ya existe un archivo de labels de ese requerimiento en el modelo (por ejemplo `GRWOVE_11`), se usa ese y se complementa; no se crea otro.
2. El ID del requerimiento se toma del nombre o título del DDF (por ejemplo "OVE_11_Validación del campo Orden del cliente").
3. Si el usuario indica otro ID explícitamente, usa ese.

Flujo:
1. Calcula `<ID>` y verifica con `file_search` si ya existen
2. Descriptores (`AxLabelFile\<ID>_<idioma>.xml`):
   - Si ya existen, no los toques.
   con PowerShell (ver Escritura de archivos) usando la plantilla de abajo.
3. Textos (`AxLabelFile\LabelResources\<idioma>\<ID>.<idioma>.label.txt`):
   para agregar labels a un archivo existente usa PowerShell (ver Escritura de archivos), no `replace_string_in_file`.
   con PowerShell, un comando por archivo (ver Escritura de archivos).
(`.rnrproj`) con PowerShell (el editor lo bloquea con la solucion abierta), dentro
```xml
<Content Include="AxLabelFile\<ID>_en-US">
  <SubType>Content</SubType>
  <Name><ID>_en-US</Name>
  <Link>Label Files\<ID>_en-US</Link>
</Content>
```
   Formato verificado en un `.rnrproj` real: agrega también `<Folder Include="Label Files\" />` si no existe y, por cada idioma, una entrada para el texto:
```xml
<Content Include="<ID>.en-US.label.txt">
  <SubType>Content</SubType>
  <Name><ID>.en-US.label.txt</Name>
  <DependentUpon>AxLabelFile\<ID>_en-US</DependentUpon>
</Content>
```
   Repite el patrón para es-MX. Informa al usuario que debe recargar el proyecto en Visual Studio.
5. Informa qué se creó, qué se complementó y qué ya existía.

Reglas de rendimiento:
1. No uses un solo comando de PowerShell que escriba todos los archivos con bucles: agota el tiempo de espera ("A task was canceled").
2. No uses `Get-ChildItem -Recurse` sobre todo el modelo; busca con `file_search` por ID.
3. Haz en paralelo solo las llamadas independientes y livianas; los comandos de PowerShell que escriben archivos van de uno en uno.

Escritura de archivos (metodo probado, evita reintentos):
1. No uses `create_file` en `K:`: falla con los `.xml` ("Could not get text view") y danya los acentos de los `.label.txt`.
2. No uses `replace_string_in_file` sobre el `.rnrproj` (el IDE lo bloquea con la solucion abierta) ni con texto acentuado (danya los acentos).
3. Usa PowerShell, un comando por archivo, y no uses here-strings (`@'...'@`): fallan en esta terminal. Arma el texto con un arreglo de lineas unido con "`r`n" o con cadenas de una linea.
4. Acentos y enie: escribe el texto con marcadores ASCII y reemplazalos por `[char]` antes de guardar: `#a`=0xE1, `#e`=0xE9, `#i`=0xED, `#o`=0xF3, `#u`=0xFA, `#n`=0xF1 (mayusculas `#A`, `#E`, `#I`, `#O`, `#U`, `#N`=0xC1, 0xC9, 0xCD, 0xD3, 0xDA, 0xD1).
5. Guarda los `.label.txt` con `[IO.File]::WriteAllText($f,$t,(New-Object Text.UTF8Encoding($true)))` (UTF-8 con BOM) y los descriptores `.xml` con `Text.UTF8Encoding($false)` (sin BOM).
6. Verifica cada archivo al terminar: `[regex]::Matches($t,[string][char]0xFFFD).Count` debe ser 0, no deben quedar marcadores `#`, y los `.xml` deben pasar `([xml]$t)`.
7. `.rnrproj`: lee el texto, inserta los `<ItemGroup>` antes de `<Import Project="$(MSBuildBinPath)\Microsoft.Common.targets" />`, valida con `[xml]`, guarda con BOM y pide al usuario recargar la solucion. Si el nombre del `Content` es invalido, revisa que el modelo del archivo coincida con `<Model>` del proyecto.

Formato del `.label.txt`:
```
<LabelId>=<Texto>
 ;<Comentario>
```
1. La línea de comentario empieza con un espacio y `;`.
2. Parámetros con `%1`, `%2`, `%3` (para `strFmt`).
3. IDs en inglés, PascalCase, sin espacios y en orden alfabético.
4. Mismo conjunto de IDs en ambos idiomas.
5. Uso en código: `"@<ID>:<LabelId>"`.

Plantilla del descriptor en-US (sin `<Language>`):
```xml
<?xml version="1.0" encoding="utf-8"?>
<AxLabelFile xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
    <Name><ID>_en-US</Name>
    <LabelContentFileName><ID>.en-US.label.txt</LabelContentFileName>
    <LabelFileId><ID></LabelFileId>
    <RelativeUriInModelStore><Modelo>\<Modelo>\AxLabelFile\LabelResources\en-US\<ID>.en-US.label.txt</RelativeUriInModelStore>
</AxLabelFile>
```

Plantilla del descriptor es-MX (agrega `<Language>es-MX</Language>` después de `<LabelFileId>` y cambia el idioma en el resto).
