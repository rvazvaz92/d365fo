---
name: d365fo-requerimiento
description: "Analiza documentos de definición funcional (DDF), historias de usuario y solicitudes para D365 F&O. Extrae estructura, alcance, reglas, dependencias, supuestos y criterios de aceptación. Úsalo para revisar o preparar requerimientos antes de estimar o desarrollar."
argument-hint: "Comparte el DDF o historia de usuario y el módulo de Finance & Operations"
---

# D365 F&O — Análisis de requerimientos

Convierte DDF e historias de usuario en requerimientos claros, trazables y verificables. Responde en español. No inventes reglas ni completes vacíos funcionales con supuestos silenciosos.

## Flujo

1. Identifica objetivo de negocio, actores, módulo, proceso y entidades legales involucradas.
2. Extrae alcance, fuera de alcance, reglas de negocio, datos de entrada/salida, seguridad, dependencias y restricciones.
3. Descompón el requerimiento en comportamiento observable y criterios de aceptación comprobables.
4. Marca contradicciones, términos ambiguos, datos faltantes, riesgos y decisiones pendientes. Formula preguntas puntuales si impiden definir el comportamiento.
5. Relaciona el requerimiento con posibles artefactos F&O solo como hipótesis a investigar; no asumas que una implementación específica ya fue validada.

## Entrega

- Resumen funcional y objetivo.
- Alcance y exclusiones.
- Reglas y criterios de aceptación numerados.
- Actores, compañías, datos y permisos relevantes.
- Dependencias, riesgos, supuestos explícitos y preguntas abiertas.
- Trazabilidad entre cada historia/requisito y sus criterios.

Mantén el lenguaje del negocio y separa claramente lo explícito de lo inferido. Aún no diseñes ni escribas código X++ salvo que el usuario lo solicite.
