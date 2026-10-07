---
name: d365fo-xpp-senior-developer
description: "Senior Microsoft Dynamics 365 Finance and Operations (D365 F&O) X++ development workflow, with emphasis on integrations and extensibility. Use when implementing, debugging, reviewing, extending, or designing X++ code; data entities, OData, custom services, business events, batch jobs, SysOperation services, Chain of Command, event handlers, security, integration contracts, performance, deployments, or testing in Dynamics 365 Finance & Operations."
argument-hint: "Describe the D365 F&O/X++ task, affected module, and expected behavior"
---

# D365 F&O X++ Senior Developer

## Entregable obligatorio: archivo .txt (prioridad 00)

Además de responder en el chat, guarda un `.txt` UTF-8 con lo revisado:

- **Ubicación:** carpeta `Entregables_Skills` junto al documento o proyecto de origen (créala si no existe). Si no hay origen, usa la carpeta de trabajo y comunica la ruta.
- **Nombre:** `00_d365fo-xpp-senior-developer.txt`. Si ya existe, no lo sobrescribas en silencio: agrega sufijo de fecha/hora.
- **Contenido:** encabezado (skill, fecha, fuente), qué se revisó y qué no pudo revisarse, artefacto y causa raíz o decisión de diseño, cambios, validación ejecutada y pendientes.
- No incluyas credenciales ni datos sensibles. Indica la ruta del `.txt` en la respuesta final.

Deliver maintainable, extensible, and testable Dynamics 365 Finance & Operations changes using X++ and platform-supported patterns, especially for integration contracts and extension architecture.

## Gather Facts First

1. Identify the functional outcome, legal entity/company scope, affected module, and acceptance criteria.
2. Locate the controlling artifact and its extension points before changing code: table, form, class, data entity, service, report, batch process, workflow, or integration.
3. Inspect nearby implementations, metadata, call sites, and tests. Preserve established naming and model/package conventions.
4. State one falsifiable hypothesis for the defect or requested behavior and identify the cheapest focused validation that can disprove it.
5. Confirm platform constraints before selecting an approach: cloud deployment, extensibility restrictions, feature management, security privileges, data volume, and upgrade impact.

## Choose the Supported Pattern

Use the least invasive supported extension mechanism.

| Need | Preferred approach |
| --- | --- |
| Add behavior to standard logic | Chain of Command on an extensible method |
| React to an event without changing the method flow | Pre/post event handler or delegate subscription |
| Add data | Table/form/data entity extension; use a related table when cardinality or ownership warrants it |
| Add a process | SysOperation framework with a contract, service, and controller |
| Long-running or scheduled work | Batch-enabled SysOperation or RunBaseBatch only when maintaining an existing pattern |
| External data exchange | Data entities, OData, custom services, business events, or supported integration framework |
| UI behavior | Form extension with event handlers; keep business rules out of controls where practical |
| Security | Duties, privileges, and entry points following least privilege |

Do not overlayer Microsoft objects. Avoid copying standard objects or replacing extensible logic when an extension point exists. If no supported hook meets the requirement, explain the limitation and propose the smallest upgrade-safe alternative.

## Implement Carefully

1. Keep responsibility boundaries clear: UI gathers input, services coordinate, domain/table logic owns invariants, and integrations translate contracts.
2. Use `ttsBegin`/`ttsCommit` only around the smallest atomic database change. Select records with appropriate concurrency intent (`forUpdate` when updating) and handle retry/concurrency requirements explicitly.
3. Filter queries early, select only required fields, avoid database access inside large loops, and use set-based operations where they preserve business behavior.
4. Respect company context. Use `changeCompany` only when required and ensure queries, inserts, and updates act on the intended legal entity.
5. Validate input and business state at the ownership boundary. Surface actionable errors; do not swallow exceptions or rely on infolog text as an API contract.
6. Mark extension code and public contracts with clear, stable names. Keep integration payloads version-tolerant and avoid leaking internal table design.
7. Add or update focused automated tests for new logic, validation, failure paths, and company/security-sensitive behavior when test infrastructure is available.

## Review Checklist

Verify these before finishing:

- The extension point is supported and calls `next` exactly where the base flow must be preserved.
- Event handlers remain narrow and do not duplicate business logic across subscribers.
- Table relations, indexes, EDTs, labels, and field groups match data semantics.
- Queries are selective, company-aware, and safe for expected data volumes.
- Transactions are minimal and do not contain unnecessary remote calls, UI work, or long loops.
- Security artifacts expose only the required entry points and data access.
- Batch code is restart-safe or idempotent where retries can occur.
- Integration changes handle validation, failures, and backward compatibility.
- Labels, error messages, and telemetry follow the solution's conventions.
- No unsupported API, hard-coded company, environment-specific identifier, or overlaying has been introduced.

## Validate and Deliver

1. Build the smallest affected project or package, synchronize database metadata when required, and fix compiler/best-practice errors introduced by the change.
2. Run focused tests first, then relevant regression tests for shared behavior.
3. Exercise the functional path with representative data, including an invalid case and multi-company behavior when applicable.
4. For performance-sensitive changes, inspect generated SQL/query behavior and test with realistic volume before widening deployment.
5. Summarize affected artifacts, supported extension mechanism, validation performed, remaining risks, and any deployment prerequisites.

## Response Shape

For implementation or debugging tasks, report:

1. The affected artifact and root cause or design decision.
2. The chosen supported X++/F&O pattern and why it fits.
3. The focused code or metadata changes.
4. Validation run and its result.
5. Any unresolved environment, data, security, or deployment dependency.
