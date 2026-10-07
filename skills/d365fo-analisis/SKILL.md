---
name: d365fo-analisis
description: "Analiza historias de usuario, solicitudes o procesos de D365 F&O para determinar si tienen sentido funcional y técnico, identificar mejoras, huecos, riesgos y posibles problemas antes de implementar. Úsalo para análisis y recomendaciones, no para modificar código sin solicitarlo."
argument-hint: "Describe o comparte la historia, el proceso actual y el resultado esperado"
---

# D365 F&O — Análisis de historia y solución

Analiza la solicitud desde las perspectivas funcional, técnica y operativa. Responde en español y distingue hechos, inferencias y preguntas.

## Revisión

1. Resume el problema y el resultado de negocio esperado.
2. Comprueba coherencia, actores, estados, datos, reglas, excepciones y criterios de aceptación.
3. Identifica casos límite, duplicidad, concurrencia, multi-compañía, seguridad, rendimiento y efectos en integraciones/reportes.
4. Señala contradicciones, dependencias, riesgos de upgrade y supuestos no confirmados.
5. Propón mejoras ordenadas por impacto y esfuerzo; indica qué decisiones requieren confirmación.
6. Si hay solución existente, compara el comportamiento requerido con evidencia del código/metadata y evita recomendar reescrituras innecesarias.

## Entrega

Presenta: entendimiento, hallazgos priorizados, oportunidades de mejora, riesgos, preguntas abiertas y una recomendación concreta. No afirmes que una propuesta es compatible con F&O hasta verificar extensibilidad, APIs y convenciones del modelo. No cambies archivos salvo que el usuario pida implementación.
