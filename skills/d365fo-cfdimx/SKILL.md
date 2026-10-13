---
name: d365fo-cfdimx
description: "Facturación electrónica de México (CFDI) en D365 F&O: catálogos SAT (EInvoiceExtCodeTable_MX y EInvoiceExtCodeType_MX), clases de generación de XML, CoC y tablas relacionadas. Úsalo al crear, extender o depurar objetos de CFDI México."
argument-hint: "Describe el catálogo SAT, la clase de generación de XML, la tabla o la extensión CoC de CFDI México que quieres revisar o crear"
---

# D365 F&O — CFDI México (facturación electrónica)

Skill base de conocimiento para facturación de México. Es de uso muy frecuente: aquí se registran los objetos estándar de CFDI, cómo se relacionan y cómo extenderlos. Se irá ampliando con cada hallazgo.

Antes de proponer cambios, confirma en el código estándar (`ApplicationSuite\Foundation`) los nombres reales de objetos y métodos. No supongas nombres.

## Catálogos SAT

Todos los catálogos del SAT se guardan en una sola tabla y se distinguen por tipo.

- **Tabla:** `EInvoiceExtCodeTable_MX` (modelo `ApplicationSuite\Foundation`, módulo `EInvoice`, país `MX`, `TableContents=BaseData`).
- **Enum de tipo:** `EInvoiceExtCodeType_MX`, un valor por catálogo.
- **Formularios:** cada catálogo tiene su formulario, filtrado por el tipo. Se abre con `EInvoiceExtCodeTable_MX::jumpRef(tipo)` que lanza el menu item `EInvoiceExtCodeTable_MX` pasando el enum en `Args` (`parmEnumType`, `parmEnum`). El lookup usa el formulario `EInvoiceExtCodeLookup_MX`.
- **Clase adaptadora de formulario:** `EInvoiceExtCodeTable_MXFormAdaptor` (`ApplicationSuiteFormAdaptor`).

### Valores del enum `EInvoiceExtCodeType_MX`

| Valor | Nombre | Catálogo |
|---|---|---|
| 0 | `TaxRegime` | Régimen fiscal |
| 1 | `ProductOrService` | Producto o servicio |
| 2 | `UnitOfMeasure` | Unidad de medida |
| 3 | `Purpose` | Uso de CFDI (propósito) |
| 4 | `PaymentMethod` | Método/forma de pago |
| 5 | `IncotermCode` | Incoterm |
| 6 | `TariffFraction` | Fracción arancelaria |
| 7 | `CustomUnitOfMeasure` | Unidad de medida aduanera |
| 8 | `ShippingReason` | Motivo de traslado |
| 9 | `PermissionType` | Tipo de permiso (autotransporte) |
| 10 | `TransConf` | Configuración de autotransporte |
| 11 | `TrailerType` | Tipo de remolque |
| 12 | `SpotType` | Tipo de ubicación |
| 13 | `ActorRole` | Rol del actor (carta porte) |
| 14 | `WeightUnit` | Unidad de peso |
| 15 | `DocumentType` | Tipo de documento (autotransporte) |
| 16 | `CustomsRegime` | Régimen aduanero |
| 17 | `CustomsMaterialType` | Tipo de materia (aduanas) |

Importante: el valor de uso de CFDI se llama `Purpose`, no `CFDIPurpose`. Un nombre incorrecto del enum no compila.

### Estructura de `EInvoiceExtCodeTable_MX`

- **Campos:** `CodeType` (enum `EInvoiceExtCodeType_MX`), `CodeId` (EDT `EInvoiceExtCodeId_MX`), `Description` (EDT `ExtCodeDescription`), `ValidFrom` (`ValidFromDate`), `validTo`, `Version` (`SysVersion`). `CodeId`, `CodeType` y `Version` no son editables.
- **Índices:** `CodeIdx` (único: `CodeType`, `Version`, `CodeId`, es el clúster y el primario) y `CodeValidFromIdx` (`CodeType`, `CodeId`, `ValidFrom`).
- **Métodos de la tabla:**
  - `find(_code, _type, _validDate, _forUpdate)`: devuelve el código vigente a la fecha (el de `ValidFrom` más reciente que no supere la fecha).
  - `jumpRef(_codeType)`: abre el formulario del catálogo.
  - `lookupCode(_ctrl, _codeType)`: lookup de un código por tipo.
  - `validateWrite()`: para `ProductOrService` exige 8 dígitos (`<:d:d:d:d:d:d:d:d>`).
- Los códigos tienen vigencia por fecha y versión: filtra siempre por `CodeType` y por vigencia.

### Uso en código propio

Al consultar un catálogo, filtra siempre por `CodeType`, o dos catálogos con el mismo `CodeId` se confunden. Ejemplo real (`GRWCustFiscalData` en `GRWCXC_99_CustFiscalInfo`):

```
select firstonly Description from eInvoiceExtCode
    where eInvoiceExtCode.CodeId == this.GRWCFDIPurposeCode
       && eInvoiceExtCode.CodeType == EInvoiceExtCodeType_MX::Purpose;
```

Los campos que guardan un código SAT usan el EDT `EInvoiceExtCodeId_MX` y su relación hacia `EInvoiceExtCodeTable_MX` por `CodeId`. Para validar el tipo, filtra en el método o relación; la relación estándar por solo `CodeId` no distingue el catálogo.

## Pendiente de registrar (se ampliará)

- Clases de generación del XML del CFDI (nodos, complementos, timbrado).
- Extensiones CoC existentes sobre tablas y clases de CFDI.
- Tablas de datos fiscales del CFDI (cliente, producto, documentos).
- Formularios de catálogos y su filtro por tipo.
- Parámetros y configuración de la facturación electrónica de México.

Al aprender un objeto nuevo, regístralo en una sección propia, con modelo, nombre real, métodos relevantes y punto de extensión (CoC o evento).

## Reglas de trabajo

- Prefiere extender con CoC o eventos; evita overlayering del modelo estándar.
- Guarda toda metadata XML en UTF-8 con BOM (ver `d365fo-tablas-tables`).
- Para crear formularios de catálogo usa `d365fo-formularios-form` y registra cada caso técnico en `d365fo-errores-encontrados`.
- Antes de modificar un catálogo SAT, considera el impacto en datos existentes, vigencias y versiones.

## Addendas fiscales por cliente (DDF 65_05)

Origen: DDF_65_05_Coflex_Addendas fiscales (Home Depot, Coppel, activaci�n a nivel cliente; requisito CXC-033).

- Una addenda es un nodo adicional al XML del CFDI, fuera del est�ndar. Su estructura y contenido los define cada cliente y deben reflejarse tal cual.
- Historias: 65_05_01 Home Depot, 65_05_02 Coppel, 65_05_03 activaci�n de addendas por cliente (par�metro a nivel cliente que decide si se genera la addenda).
- Antes de desarrollar, obt�n el XML de ejemplo y el mapeo de campos de cada cliente; no supongas nodos ni atributos.
- Punto de extensi�n: confirma en el c�digo est�ndar la clase real que arma el XML del CFDI y exti�ndela con CoC. No hagas overlayering.
- Genera la addenda solo si el cliente la tiene activada; sin activaci�n, el XML debe quedar igual al est�ndar.
- Valida la addenda contra el ejemplo del cliente para evitar rechazos.
