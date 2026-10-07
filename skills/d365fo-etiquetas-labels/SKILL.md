---
name: d365fo-etiquetas-labels
description: "Crea, selecciona y asigna labels de Dynamics 365 F&O a campos, formularios, tablas, mensajes y otros metadatos. Revisa archivo de etiquetas, idioma, convenciones, reutilización y calidad de mensajes."
argument-hint: "Indica el texto, idioma, artefacto y contexto donde se mostrará la etiqueta"
---

# D365 F&O — Etiquetas

Usa etiquetas localizables y convenciones del modelo para todo texto presentado al usuario.

## Procedimiento

- Busca si ya existe una etiqueta equivalente y reutilízala cuando su significado coincida.
- Si falta, crea una etiqueta con ID estable, conciso y conforme a las convenciones del proyecto.
- Añade traducciones en los idiomas requeridos por la solución cuando estén disponibles.
- Asigna la etiqueta al campo, EDT, formulario, control o mensaje correcto; valida que el tipo de propiedad admita label.
- Distingue caption, help text, error y texto interno de diagnóstico.
- No pongas texto visible hard-coded en X++ o metadata cuando deba ser localizable.

Verifica resolución de la etiqueta en los idiomas soportados y compila/sincroniza cuando sea necesario. No inventes IDs ya existentes; inspecciona el archivo/modelo de labels antes de elegir uno.
