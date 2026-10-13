
## Deploy de reportes SSRS estándar por PowerShell (sin Visual Studio)

Usa `DeployAllReportsToSSRS.ps1` para desplegar un reporte estándar o propio sin abrir Visual Studio.

**Requisitos**
- PowerShell como Administrador en el servidor D365 F&O.
- Servicios activos: IIS, Batch, DIXF, SSRS y MR.
- Script (ruta por defecto): `K:\AosService\PackagesLocalDirectory\Plugins\AxReportVmRoleStartupTask\DeployAllReportsToSSRS.ps1`. Ajusta si el ambiente difiere.
- Si modificaste el reporte, compila el modelo antes de desplegar.

**Comandos** (`$s` = ruta del script, `$p` = `K:\AosService\PackagesLocalDirectory`)
- Todos: `& $s -PackageInstallLocation $p`
- Un reporte (nombre exacto `Reporte.Design`): `& $s -PackageInstallLocation $p -ReportName EInvoiceCFDIReport_MX.Report`
- Un módulo: `& $s -PackageInstallLocation $p -Module <Modulo>`
- Comodín: `& $s -PackageInstallLocation $p -ReportName *Purch*`

**Notas**
- Prefiere `-ReportName` exacto; desplegar todo es lento.
- Cada design se despliega por separado: `EInvoiceCFDIReport_MX.PackingSlipReport`.
- Verifica que `PackageInstallLocation` coincida con el ambiente.
- Se puede automatizar en un .ps1 o .bat.
