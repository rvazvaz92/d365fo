---
name: d365fo-userinterface
description: Estructura XML de referencia para extensiones de menú (AxMenuExtension) en D365FO y reglas para agregar menu items a menús estándar como Cuentas por cobrar > Configuración.
---

# D365FO: interfaz de usuario (menús)

## Estructura correcta de `AxMenuExtension`
Archivo: `AxMenuExtension\<MenuBase>.<Modelo>.xml` (por ejemplo `AccountsReceivable.GRWFactoring.xml`).

```xml
<?xml version="1.0" encoding="utf-8"?>
<AxMenuExtension xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="Microsoft.Dynamics.AX.Metadata.V1">
	<Name>AccountsReceivable.GRWFactoring</Name>
	<Customizations />
	<Elements>
		<AxMenuExtensionElement xmlns="">
			<Parent>Customers</Parent>
			<MenuElement xmlns=""
				i:type="AxMenuElementMenuItem">
				<Name>GrwFactoringServiceLender</Name>
				<MenuItemName>GrwFactoringServiceLender</MenuItemName>
			</MenuElement>
		</AxMenuExtensionElement>
	</Elements>
	<MenuElementModifications />
	<PropertyModifications />
</AxMenuExtension>
```

## Reglas
- El namespace raíz es `Microsoft.Dynamics.AX.Metadata.V1`; los hijos de `AxMenuExtensionElement` y `MenuElement` llevan `xmlns=""`.
- El nombre del elemento va dentro de `MenuElement`, no directo en `AxMenuExtensionElement`. Un `AxMenuExtensionElement` con `<Name>` directo y sin `MenuElement` provoca `NullReferenceException` en `AxMenuExtensionElement.get_Name()` y rompe toda la compilación (`Failed to write runtime metadata to disk`).
- El nombre del archivo sigue el patrón del estándar: `<MenuBase>.<Modelo>.xml`. El sufijo `_Extension` no se comprobó como causa de error; el fallo documentado se debe a la estructura plana.
- Un elemento por `AxMenuExtensionElement`. Cada uno con su `Parent`.
- `Parent` es el nombre del submenú estándar. Valores de Cuentas por cobrar:
  - `Setup`: Configuración.
  - `Customers`: Clientes.
  - `PeriodicProcesses`: Procesos periódicos.
  - `InquiriesAndReports`: Consultas e informes.
- Tipos en `i:type`: `AxMenuElementMenuItem` para menu items. Para submenús propios, `AxMenuElementSubMenu` (con `Name` y `Elements`), como hace `LTMMenu_Setup`.
- Formato: tabulaciones, CRLF y BOM UTF-8.

## Ruta del modelo
- Cuentas por cobrar > Configuración > Validación fiscal de clientes: `Parent` = `Setup`, menu item `GRWCustFiscalData`.
- Cuentas por cobrar > Configuración > Validación RFC clientes: `Parent` = `Setup`, menu item `GRWCustRFCCatalog`.

## Checklist
1. El menu item (`AxMenuItemDisplay`) existe y apunta al formulario.
2. La extensión usa la estructura de arriba.
3. Menu item y extensión están en el `.rnrproj` (`Content Include`).
4. Privilegios `Maintain` y `View` apuntan al menu item.
5. Recompilar el modelo.

## Escritura de archivos
Ver `d365fo-escritura-archivos`.
