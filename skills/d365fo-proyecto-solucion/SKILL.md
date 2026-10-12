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
