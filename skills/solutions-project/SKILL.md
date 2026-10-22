---
name: solutions-project
description: Estructura para crear una soluci�n (.sln) y un proyecto D365FO (.rnrproj) nuevos para un modelo, y registrar sus objetos. �sala cuando haya que crear soluci�n y proyecto desde cero. Para agregar objetos a un proyecto existente usa tambi�n d365fo-proyecto-solucion.
---

# solutions-project

Estructura para crear una soluci�n y un proyecto de D365FO para un modelo y agregarle sus objetos.

## Cu�ndo usarla
- Se pide crear soluci�n y proyecto para un modelo que a�n no los tiene.
- Antes de crear, revisa si ya existen (`<repo>\<Solucion>.sln` y `<repo>\<Proyecto>\<Proyecto>.rnrproj`). Si existen, no los recrees: solo compara y registra lo que falte.
- El registro de objetos sigue las reglas de `d365fo-proyecto-solucion` (respaldo `.bak`, sin duplicar, orden alfab�tico, el objeto debe existir en disco).

## Estructura en disco
```
<repo>\
  <Solucion>.sln
  <Proyecto>\
    <Proyecto>.rnrproj
```
- El modelo vive en `K:\AosService\PackagesLocalDirectory\<Modelo>\<Modelo>\Ax<Tipo>\<Objeto>.xml`.
- El nombre del proyecto no tiene que coincidir con el del modelo. La propiedad `<Model>` del `.rnrproj` es la que enlaza con el modelo real. Confirma el nombre exacto del modelo en `PackagesLocalDirectory`.

## Pasos
1. Confirma con el usuario: nombre de soluci�n, nombre de proyecto y modelo (nombre exacto en `PackagesLocalDirectory`).
2. Genera dos GUID nuevos: uno para el proyecto (`ProjectGuid`) y otro para la soluci�n (`SolutionGuid`).
3. Crea el `.rnrproj` con la plantilla de abajo.
4. Crea el `.sln` con la plantilla de abajo. El GUID del proyecto va en may�sculas en el `.sln` y en min�sculas en el `.rnrproj`.
5. Lista los objetos del modelo en disco (`Ax*\*.xml`, sin la carpeta `Descriptor`) y reg�stralos como `<Content>` m�s las `<Folder>` necesarias, seg�n la tabla de tipos de `d365fo-proyecto-solucion`.
6. Verifica: que el `.rnrproj` sea XML v�lido (`[xml](Get-Content <ruta> -Raw)`) y que lo registrado coincida con lo que hay en disco, en ambos sentidos.
7. Pide al usuario abrir o recargar la soluci�n en Visual Studio, compilar y comprobar el Solution Explorer.
8. Escribe los archivos en UTF-8 y no sobrescribas un proyecto existente.

## Plantilla `.rnrproj`
```xml
<Project ToolsVersion="14.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <BuildTasksDirectory Condition=" '$(BuildTasksDirectory)' == ''">$(MSBuildProgramFiles32)\MSBuild\Microsoft\Dynamics\AX</BuildTasksDirectory>
    <Model><Modelo></Model>
    <TargetFrameworkVersion>v4.6</TargetFrameworkVersion>
    <OutputPath>bin</OutputPath>
    <SchemaVersion>2.0</SchemaVersion>
    <GenerateCrossReferences>True</GenerateCrossReferences>
    <RunAppCheckerRules>False</RunAppCheckerRules>
    <LogAppcheckerDiagsAsErrors>False</LogAppcheckerDiagsAsErrors>
    <DeployOnline>False</DeployOnline>
    <ProjectGuid>{<guid-minusculas>}</ProjectGuid>
    <Name><Proyecto></Name>
    <RootNamespace><Proyecto></RootNamespace>
    <StartupType>Class</StartupType>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'">
    <Configuration>Debug</Configuration>
    <DBSyncInBuild>True</DBSyncInBuild>
    <GenerateFormAdaptors>False</GenerateFormAdaptors>
    <Company>
    </Company>
    <Partition>initial</Partition>
    <PlatformTarget>AnyCPU</PlatformTarget>
    <DataEntityExpandParentChildRelations>False</DataEntityExpandParentChildRelations>
    <DataEntityUseLabelTextAsFieldName>False</DataEntityUseLabelTextAsFieldName>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <DebugSymbols>true</DebugSymbols>
    <EnableUnmanagedDebugging>false</EnableUnmanagedDebugging>
  </PropertyGroup>
  <ItemGroup>
    <Folder Include="Classes\" />
  </ItemGroup>
  <ItemGroup>
    <Content Include="AxClass\<Objeto>">
      <SubType>Content</SubType>
      <Name><Objeto></Name>
      <Link>Classes\<Objeto></Link>
    </Content>
  </ItemGroup>
  <Import Project="$(MSBuildBinPath)\Microsoft.Common.targets" />
  <Import Project="$(BuildTasksDirectory)\Microsoft.Dynamics.Framework.Tools.BuildTasks.17.0.targets" />
</Project>
```
Incluye en el primer `ItemGroup` solo las carpetas de los tipos que el proyecto realmente usa.

## Plantilla `.sln`
```
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.14.37027.9
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FC65038C-1B2F-41E1-A629-BED71D161FFF}") = "<Proyecto> (VAR) [<Modelo>]", "<Proyecto>\<Proyecto>.rnrproj", "{<GUID-MAYUSCULAS>}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{<GUID-MAYUSCULAS>}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{<GUID-MAYUSCULAS>}.Debug|Any CPU.Build.0 = Debug|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {<GUID-SOLUCION>}
	EndGlobalSection
EndGlobal
```
- `{FC65038C-1B2F-41E1-A629-BED71D161FFF}` es el tipo de proyecto de Finance and Operations. No lo cambies.
- Si Visual Studio ya tiene abierta la soluci�n, pide al usuario recargarla.

## Ejemplo real
Soluci�n `GRWPRE_002_Maniobras.sln` con proyecto `GRWPRE_002_Maniobras.rnrproj` y `<Model>GRWPRE_002_Fletes</Model>`. Registra clases, tablas, extensiones de tabla, formularios, extensi�n de formulario, extensi�n de men�, men� display, privilegios, un duty ya existente en disco y etiquetas (`en-US`, `es-MX`). Los roles no se registran.


## Regla: ubicacion unica para editar skills

- Todo cambio a una skill (SKILL.md, scripts o ejemplos) se hace SIEMPRE en `C:\Users\Admin0e2edd3f30\source\repos\d365fo\skills\<skill>\`.
- No editar las copias dentro de otras soluciones (por ejemplo `GRW_DDF_6505\d365fo\skills`); son solo de lectura y se actualizan copiando desde este repositorio.
- Despues de editar, ejecutar `Sync-Skill.ps1` desde `C:\Users\Admin0e2edd3f30\source\repos\d365fo` para hacer add, commit y push.
- Si el push es rechazado por cambios remotos: `git pull --rebase` y `git push`.
- Si se detecta una copia con diferencias, compararla contra este repositorio antes de copiar: solo se integran lineas que falten aqui; nunca sobrescribir el repositorio con una copia atrasada.
