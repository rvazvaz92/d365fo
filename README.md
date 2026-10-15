# d365fo
Repositorio para desarrollo en Dynamics 365 Finance and Operation UP39+

## Skills de Copilot (`skills/`)

Esta carpeta contiene las skills de Copilot/GitHub Copilot CLI para el ciclo de vida de desarrollo en D365 F&O/X++. Cada subcarpeta es una skill independiente con su `SKILL.md`.

| Skill | Para qué sirve |
| --- | --- |
| `d365fo-xpp-senior-developer` | Flujo general de desarrollo senior en X++ (patrones soportados, CoC, SysOperation, integraciones). |
| `d365fo-requerimiento` | Revisar DDF, alcance, reglas y criterios de aceptación. |
| `d365fo-analisis` | Analizar historias de usuario, riesgos y mejoras. |
| `d365fo-test-case` | Diseñar casos de prueba funcionales. |
| `d365fo-requerimientos-vs-test-case` | Validar trazabilidad entre requerimientos y pruebas. |
| `d365fo-proyecto-solucion` | Analizar arquitectura y solución actual del proyecto. |
| `d365fo-clases-class` | Clases X++: CoC, event handlers, SysOperation. |
| `d365fo-tablas-tables` | Tablas, campos, EDTs, relaciones e índices. |
| `d365fo-entidades-entities` | Data entities para integraciones y OData. |
| `d365fo-formularios-form` | Formularios y extensiones de UI. |
| `d365fo-reportes-report` | Reportes según fuente de datos y tipo de ejecución. |
| `d365fo-seguridad-privilegios` | Roles, duties, privileges y acceso mínimo necesario. |
| `d365fo-etiquetas-labels` | Etiquetas localizables para metadatos. |
| `d365fo-errores-encontrados` | Wiki de errores encontrados, causa raíz y solución. |
| `d365fo-userinterface` | Extensiones de menú (AxMenuExtension) y menu items estándar de D365FO. |
| `d365fo-escritura-archivos` | Cómo crear y editar metadatos XML en `PackagesLocalDirectory` sin que fallen las herramientas ni el terminal. |

### Regla de trabajo

- Todas las skills, nuevas o mejoradas, se crean y se editan únicamente en `source\repos\d365fo\skills\<skill>\SKILL.md`. No se mantienen copias en `.github\skills` de los repos de los modelos ni en `.agents\skills`; esta última solo contiene junctions.
- Antes de crear una skill, busca si ya existe una equivalente en `skills\` y extiéndela con una sección nueva en lugar de duplicarla.
- Guarda los `SKILL.md` en UTF-8 sin BOM y revisa que los acentos no queden dañados.
- La nomenclatura de cualquier extensión (clase, tabla, entidad, menú, formulario) varía según el modelo: los nombres de los ejemplos son ilustrativos y no deben copiarse de un modelo a otro.
- Tras cada cambio, haz commit y push desde este repositorio.

### Cómo sincronizar estas skills en una máquina nueva

1. Clona este repositorio (o haz `git pull` si ya lo tienes):
   ```powershell
   git clone https://github.com/rvazvaz92/d365fo.git C:\Users\<usuario>\source\repos\d365fo
   ```
2. Enlaza cada carpeta de `skills/` dentro del directorio global de skills del agente (`C:\Users\<usuario>\.agents\skills`) usando una *junction* (no copia, para que quede sincronizado con git):
   ```powershell
   foreach ($d in Get-ChildItem "C:\Users\<usuario>\source\repos\d365fo\skills" -Directory) {
     $link = "C:\Users\<usuario>\.agents\skills\$($d.Name)"
     if (-not (Test-Path $link)) {
       cmd /c mklink /J "$link" "$($d.FullName)"
     }
   }
   ```
3. Cuando generes o mejores una skill, edita el archivo dentro de `source\repos\d365fo\skills\<skill>\SKILL.md` y luego:
   ```powershell
   cd C:\Users\<usuario>\source\repos\d365fo
   git add -A
   git commit -m "Actualiza skill <nombre> con nuevo aprendizaje"
   git push
   ```
4. En cualquier otra sesión/máquina, ejecuta `git pull` dentro de `source\repos\d365fo` para traer lo último; como las skills están enlazadas por *junction*, no hace falta copiar nada más.

# Regla Global de Trabajo para IA y Copilot

## Repositorio Fuente de Verdad

Este repositorio es la fuente principal de conocimiento para el ciclo completo de desarrollo en Microsoft Dynamics 365 Finance & Operations (D365FO) y X++.

Repositorio:

https://github.com/rvazvaz92/d365fo

Toda IA, asistente o Copilot que trabaje sobre requerimientos, análisis, diseño, desarrollo, testing, documentación o soporte de D365FO debe:

1. Revisar primero la versión más reciente del repositorio.
2. Utilizar las skills contenidas en la carpeta `skills/` como fuente principal de reglas y convenciones.
3. Priorizar las reglas definidas en los archivos `SKILL.md` antes de utilizar recomendaciones genéricas de D365FO.
4. Cuando exista una diferencia entre conocimiento general y las reglas del repositorio, documentar la diferencia y priorizar el repositorio.
5. Tratar el repositorio como una base de conocimiento viva que puede cambiar diariamente.

## Orden de Prioridad

1. Skills del repositorio d365fo.
2. Código existente del modelo/proyecto.
3. Buenas prácticas Microsoft D365FO.
4. Recomendaciones genéricas de arquitectura.

## Skills Base

Las siguientes skills son consideradas obligatorias para cualquier análisis o desarrollo:

- d365fo-xpp-senior-developer
- d365fo-requerimiento
- d365fo-analisis
- d365fo-test-case
- d365fo-requerimientos-vs-test-case
- d365fo-proyecto-solucion
- d365fo-clases-class
- d365fo-tablas-tables
- d365fo-entidades-entities
- d365fo-formularios-form
- d365fo-reportes-report
- d365fo-seguridad-privilegios
- d365fo-etiquetas-labels
- d365fo-errores-encontrados
- d365fo-escritura-archivos
- d365fo-userinterface
- d365fo-cfdimx
- solutions-project

## Principios de Desarrollo

- Preferir Chain of Command.
- Usar Event Handlers únicamente cuando sea necesario o solicitado explícitamente.
- No realizar overlayering.
- Utilizar patrones upgrade-safe.
- Respetar la nomenclatura del modelo actual.
- Utilizar labels para todo texto visible al usuario.
- Aplicar mínimo privilegio en seguridad.
- Mantener compatibilidad con actualizaciones de Microsoft.
- Documentar errores encontrados y lecciones aprendidas.
- Priorizar extensibilidad antes que personalización invasiva.

## Flujo Oficial

Requerimiento
→ Análisis
→ Test Case
→ Diseño Técnico
→ Implementación
→ Seguridad
→ Validación
→ Documentación

## Revisión Inicial Obligatoria

Antes de comenzar cualquier tarea nueva:

1. Revisar si existe una actualización del repositorio.
2. Revisar la skill relacionada con el tipo de artefacto a modificar.
3. Revisar errores históricos registrados.
4. Revisar convenciones del modelo actual.
5. Confirmar que el enfoque propuesto sigue los patrones soportados por Microsoft.

## Gestión de Conocimiento

Todo aprendizaje nuevo debe registrarse en la skill correspondiente para evitar perder conocimiento y permitir su reutilización por futuras sesiones de trabajo, GitHub Copilot, M365 Copilot o cualquier otra herramienta de IA utilizada por el equipo.
