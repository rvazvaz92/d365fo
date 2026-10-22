---
name: d365fo-test-case
description: "Diseña y revisa casos de prueba funcionales para historias y cambios de Microsoft Dynamics 365 Finance & Operations, incluyendo precondiciones, datos, pasos y resultados esperados. Úsalo para crear una suite de pruebas trazable y reproducible."
argument-hint: "Comparte la historia, sus criterios de aceptación y el proceso o módulo afectado"
---

# D365 F&O — Diseño de test cases

## Entregable obligatorio: archivo .txt (prioridad 03)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento de origen (créala si no existe). Si no hay documento de origen, usa la carpeta de trabajo y comunica la ruta.
- **Modelo:** el usuario debe indicar el nombre del modelo (por ejemplo, `GRWCXC_99_CustFiscalInfo`) para identificar de dónde proviene el conocimiento. Si no lo indicó, pregúntalo con ask_user (respuesta libre) antes de guardar el `.txt`; reutilízalo en toda la cadena y en la sesión. Escríbelo en el encabezado como `Modelo : <nombre>`.
- **Nombre:** `03_d365fo-test-case_<MODELO>.txt` (prefijo de prioridad, nombre de la skill y modelo, en ese orden). Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, ruta de la fuente), qué se revisó y qué no pudo revisarse, la suite de casos completa, preguntas abiertas y la siguiente skill sugerida.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

## Encadenamiento automático

- **Entrada:** usa los `.txt` 01 y 02 de la misma fuente y del mismo modelo si existen, y verifica contra la fuente cuando algo no cuadre.
- **Salida:** es el final de la cadena automática. Al terminar, solo **sugiere** `d365fo-requerimientos-vs-test-case` para validar la trazabilidad; no la ejecutes sin que el usuario lo pida.

Genera casos de prueba ejecutables y trazables a criterios de aceptación. Responde en español; conserva nombres reales de menús/campos cuando se conozcan y nunca los inventes.

## Cobertura requerida

- Camino exitoso y reglas de negocio.
- Datos inválidos, campos obligatorios y límites.
- Permisos y roles cuando afecten el resultado.
- Entidad legal y segregación de datos.
- Duplicados, reintentos, concurrencia y transiciones de estado cuando apliquen.
- Regresión focalizada en procesos relacionados.

## Formato por caso

Incluye ID, criterio relacionado, objetivo, prioridad, precondiciones, rol/compañía, datos de prueba, pasos numerados y resultado esperado verificable por paso. Separa preparación de datos del procedimiento.

## Reglas

No conviertas una expectativa ambigua en un resultado esperado inventado: registra la pregunta abierta. Evita pasos vagos como “validar que funciona”. Señala datos destructivos o ambientes compartidos y no ejecutes operaciones de producción sin autorización explícita.

## Casos registrados: validacion fiscal al confirmar orden de venta

- **Modelo:** GRWCXC_99_CustFiscalInfo. **Objetos:** GRWSalesFormLetter_CXC_99_Extension (CoC de SalesFormLetter.validate), GRWSalesTable_CXC_99_Extension (validateWrite y grwValidateCustomerFiscalData), GRWCustFiscalData (existsCombination), CustParameters.GRWCustFiscalValidate. Sin compilar ni probar en ejecucion.
- **Regla del codigo a probar:** con el parametro en Si, al confirmar una orden se valida, por cada orden seleccionada, que el cliente tenga RFC, regimen fiscal y uso CFDI, y que la combinacion exista en GRWCustFiscalData. Si falla, mensaje CXC99_043 y se bloquea la confirmacion. Con el parametro en No, no se valida.
- **Dato tecnico que afecta el diseno de pruebas:** en SalesFormLetter, documentStatus() devuelve el tipo de documento que se registra (SalesFormLetter_Confirm devuelve DocumentStatus::Confirmation), no el estado de la orden. El estado de la orden esta en SalesTable.SalesStatus y el ultimo documento registrado en SalesTable.DocumentStatus. No asumir que la orden ya esta confirmada cuando se ejecuta la validacion.
- **Pregunta abierta (sin respuesta del usuario):** la validacion debe aplicarse solo a ordenes en estado Backorder aun no confirmadas, o siempre que se confirme, incluida una reconfirmacion. No definir resultado esperado para la reconfirmacion hasta que se responda.

**Casos a disenar (completar IDs, datos y pasos con el formato por caso):**

1. Parametro en Si, cliente con RFC, regimen y uso CFDI validos y combinacion existente en GRWCustFiscalData: la confirmacion se completa.
2. Parametro en Si, cliente sin RFC: se bloquea la confirmacion y se muestra el mensaje CXC99_043.
3. Parametro en Si, cliente sin regimen fiscal o sin uso CFDI: se bloquea y se muestra CXC99_043.
4. Parametro en Si, cliente con regimen y uso CFDI que no forman una combinacion de GRWCustFiscalData: se bloquea y se muestra CXC99_043.
5. Cliente con varias combinaciones en GRWCustFiscalData y una coincide con sus datos: la confirmacion se completa.
6. Parametro en No, cliente sin datos fiscales: la confirmacion se completa sin mensaje.
7. Confirmar varias ordenes a la vez, una con cliente invalido: se muestra el error y no se confirma ninguna. Verificar si se confirman las validas (pregunta abierta: comportamiento esperado).
8. Crear una orden de venta con parametro en Si y cliente invalido: segun GRWSalesTable_CXC_99_Extension.validateWrite se bloquea el guardado. Verificar tambien al modificar una orden existente.
9. Orden en estado Backorder frente a orden ya confirmada (reconfirmacion): resultado esperado pendiente de la pregunta abierta.
10. Otros documentos (lista de picking, albaran, factura) con cliente invalido: no se valida en la confirmacion; confirmar el comportamiento esperado antes de fijar el resultado.
11. Rol sin permiso sobre CustParameters o GRWCustFiscalData: verificar que el resultado de la validacion no cambia segun el rol.
12. Dos compañias con datos fiscales distintos: la validacion usa los datos de la compañia actual.

## Regla general: matriz de reglas DDF vs codigo (aplica a TODO DDF)

- Se ejecuta para cada DDF que el usuario indique por nombre, no solo para uno en particular. Si no indica el DDF, preguntarlo.
- Fuente: el .docx en C:\Users\Admin0e2edd3f30\source\repos\DDF (lectura segun d365fo-requerimiento). Codigo: K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo> y el .rnrproj de la solucion.
- Extraer del DDF todas las reglas: campos numerados (tipo, longitud, editable, obligatorio, valor por omision), funcionalidad, seguridad, entidades y cada ID del Script de Pruebas.
- Matriz: ID regla | Regla | Ref DDF | Objeto(s) en codigo | Estado (CUBIERTO / PARCIAL / NO CUBIERTO / CONFLICTO) | Observacion. Marcar las reglas inferidas como 'Inferido'. Resumen con conteo real por estado.
- Revisar el XML real de cada objeto: no dar por cubierta una regla solo porque el objeto existe (metodos sin llamador, form sin filtro, longitudes distintas = PARCIAL).
- Suite: un caso por regla o grupo de reglas, ligado al ID del DDF; marcar BLOQUEADO lo que depende de objetos faltantes o preguntas abiertas; indicar el resultado esperado por codigo cuando se prevea falla.
- Contradicciones del DDF (campo vs script, flujo vs flujo) van como CONFLICTO y pregunta abierta, nunca resueltas por suposicion.
- Entregable: Entregables_Skills\03_d365fo-test-case_<MODELO>.txt junto a la solucion del modelo. Ejemplo de referencia: DDF_65_05 / GRW_65_05_TaxAddendums (30 reglas, 18 casos).

## Entregable Word de la matriz (aplica a TODO DDF)

- Ademas del .txt, generar la matriz en Word con el script `Export-MatrizDocx.ps1` (en la carpeta de esta skill). No requiere Office.
- Entrada: `Entregables_Skills\03_matriz_<MODELO>.psv` en UTF-8, primera linea `ID|Regla|Ref DDF|Objeto(s) en codigo|Estado|Observacion`, una regla por linea (no usar el caracter | dentro del texto).
- Comando: `powershell -ExecutionPolicy Bypass -File <skill>\Export-MatrizDocx.ps1 -MatrixPath <psv> -OutPath Entregables_Skills\03_Matriz_<DDF>_<MODELO>.docx -Title 'Matriz de reglas DDF vs codigo - <DDF>' -Subtitle 'Modelo: <MODELO> | Fecha: <AAAA-MM-DD> | Estado: <compilado/probado o no>'`.
- Resultado: hoja horizontal con tabla de resumen por estado y tabla de matriz con encabezado repetido y color por estado (verde CUBIERTO, amarillo PARCIAL, rojo NO CUBIERTO, naranja CONFLICTO). Si el .docx existe, el script agrega sufijo de fecha/hora.
- Validar que el conteo del resumen del .docx coincida con el del .txt e indicar la ruta del .docx en la respuesta final.
