<#
.SYNOPSIS
    Sincroniza (add + commit + push) los cambios de las skills de D365FO con el repositorio git.

.DESCRIPTION
    Pensado para usarse despues de generar o mejorar una skill editando
    source\repos\d365fo\skills\<skill>\SKILL.md.
    Hace git add -A, commit y push automaticamente.
    Se detiene con error si git add, commit o push fallan.

.PARAMETER Skill
    Nombre de la skill modificada (se usa en el mensaje de commit).

.PARAMETER Message
    Mensaje de commit personalizado. Si se indica, tiene prioridad sobre -Skill.

.EXAMPLE
    .\Sync-Skill.ps1 -Skill d365fo-tablas-tables

.EXAMPLE
    .\Sync-Skill.ps1 -Message "Agrega ejemplos de extensiones de tabla"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Skill,

    [Parameter()]
    [string]$Message
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git $($GitArgs -join ' ') fallo con codigo $LASTEXITCODE."
        exit $LASTEXITCODE
    }
}

# Raiz del repositorio = carpeta donde esta este script
$repoRoot = $PSScriptRoot
Set-Location $repoRoot

# Verifica que sea un repo git
if (-not (Test-Path (Join-Path $repoRoot '.git'))) {
    Write-Error "El directorio '$repoRoot' no es un repositorio git."
    exit 1
}

# Verifica que git tenga identidad configurada
$userName = (& git config user.name)
$userEmail = (& git config user.email)
if ([string]::IsNullOrWhiteSpace($userName) -or [string]::IsNullOrWhiteSpace($userEmail)) {
    Write-Error "Git no tiene identidad. Ejecuta: git config user.name 'Nombre'; git config user.email 'correo'"
    exit 1
}

# Verifica si hay cambios
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No hay cambios para sincronizar." -ForegroundColor Yellow
    exit 0
}

# Construye el mensaje de commit
if (-not $Message) {
    if ($Skill) {
        $Message = "Actualiza skill $Skill con nuevo aprendizaje"
    } else {
        $Message = "Actualiza skills con nuevo aprendizaje"
    }
}

Write-Host "Cambios detectados:" -ForegroundColor Cyan
git status --short

Invoke-Git add -A
Invoke-Git commit -m $Message
Invoke-Git push

Write-Host "`nSkills sincronizadas correctamente." -ForegroundColor Green
