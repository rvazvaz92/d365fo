param(
    [Parameter(Mandatory)] [string] $MatrixPath,
    [Parameter(Mandatory)] [string] $OutPath,
    [string] $Title = 'Matriz de reglas DDF vs codigo',
    [string] $Subtitle = '',
    [string] $Delimiter = '|'
)
# Genera un .docx con la matriz de reglas (tabla con encabezado, colores por estado y resumen).
# Entrada: archivo UTF-8, primera linea = encabezados, una regla por linea, columnas separadas por $Delimiter.
# Debe existir una columna llamada 'Estado' (CUBIERTO / PARCIAL / NO CUBIERTO / CONFLICTO).
# No requiere Office: arma el paquete OpenXML con System.IO.Compression.

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Esc([string]$s) { [System.Security.SecurityElement]::Escape($s) }

function Par([string]$text, [bool]$bold = $false, [int]$size = 18) {
    $b = if ($bold) { '<w:b/>' } else { '' }
    "<w:p><w:pPr><w:spacing w:after='0'/></w:pPr><w:r><w:rPr>$b<w:sz w:val='$size'/></w:rPr><w:t xml:space='preserve'>$(Esc $text)</w:t></w:r></w:p>"
}

function Cell([string]$text, [string]$fill, [bool]$bold, [int]$width) {
    $shd = if ($fill) { "<w:shd w:val='clear' w:color='auto' w:fill='$fill'/>" } else { '' }
    "<w:tc><w:tcPr><w:tcW w:w='$width' w:type='dxa'/>$shd</w:tcPr>$(Par $text $bold 16)</w:tc>"
}

$lines = [IO.File]::ReadAllLines($MatrixPath, [Text.Encoding]::UTF8) | Where-Object { $_.Trim() }
$header = $lines[0].Split($Delimiter) | ForEach-Object { $_.Trim() }
$rows = $lines | Select-Object -Skip 1 | ForEach-Object { ,($_.Split($Delimiter) | ForEach-Object { $_.Trim() }) }
$estadoIdx = [Array]::IndexOf($header, 'Estado')

$colors = @{ 'CUBIERTO' = 'C6EFCE'; 'PARCIAL' = 'FFEB9C'; 'NO CUBIERTO' = 'FFC7CE'; 'CONFLICTO' = 'F4B183' }

# Anchos (dxa) en hoja horizontal: total aprox. 14000
$weights = @{ 'ID' = 600; 'Regla' = 3600; 'Ref DDF' = 1300; 'Objeto(s) en codigo' = 3000; 'Estado' = 1300; 'Observacion' = 4200 }
$widths = $header | ForEach-Object { if ($weights.ContainsKey($_)) { $weights[$_] } else { 2000 } }

$sb = New-Object Text.StringBuilder
[void]$sb.Append((Par $Title $true 32))
if ($Subtitle) { foreach ($s in $Subtitle.Split("`n")) { [void]$sb.Append((Par $s $false 18)) } }
[void]$sb.Append((Par '' $false 18))

# Resumen por estado
if ($estadoIdx -ge 0) {
    [void]$sb.Append((Par "Resumen ($($rows.Count) reglas)" $true 22))
    [void]$sb.Append("<w:tbl><w:tblPr><w:tblStyle w:val='TableGrid'/><w:tblBorders><w:top w:val='single' w:sz='4'/><w:left w:val='single' w:sz='4'/><w:bottom w:val='single' w:sz='4'/><w:right w:val='single' w:sz='4'/><w:insideH w:val='single' w:sz='4'/><w:insideV w:val='single' w:sz='4'/></w:tblBorders></w:tblPr>")
    [void]$sb.Append("<w:tr>$(Cell 'Estado' '1F4E79' $true 2500)$(Cell 'Cantidad' '1F4E79' $true 1500)</w:tr>")
    foreach ($e in 'CUBIERTO', 'PARCIAL', 'NO CUBIERTO', 'CONFLICTO') {
        $n = @($rows | Where-Object { $_[$estadoIdx] -eq $e }).Count
        [void]$sb.Append("<w:tr>$(Cell $e $colors[$e] $false 2500)$(Cell "$n" '' $false 1500)</w:tr>")
    }
    [void]$sb.Append('</w:tbl>')
    [void]$sb.Append((Par '' $false 18))
}

# Matriz
[void]$sb.Append((Par 'Matriz de reglas' $true 22))
[void]$sb.Append("<w:tbl><w:tblPr><w:tblW w:w='0' w:type='auto'/><w:tblBorders><w:top w:val='single' w:sz='4'/><w:left w:val='single' w:sz='4'/><w:bottom w:val='single' w:sz='4'/><w:right w:val='single' w:sz='4'/><w:insideH w:val='single' w:sz='4'/><w:insideV w:val='single' w:sz='4'/></w:tblBorders><w:tblLayout w:type='fixed'/></w:tblPr><w:tblGrid>")
foreach ($w in $widths) { [void]$sb.Append("<w:gridCol w:w='$w'/>") }
[void]$sb.Append('</w:tblGrid>')
[void]$sb.Append("<w:tr><w:trPr><w:tblHeader/></w:trPr>")
for ($i = 0; $i -lt $header.Count; $i++) { [void]$sb.Append((Cell $header[$i] 'BDD7EE' $true $widths[$i])) }
[void]$sb.Append('</w:tr>')
foreach ($r in $rows) {
    [void]$sb.Append('<w:tr><w:trPr><w:cantSplit/></w:trPr>')
    for ($i = 0; $i -lt $header.Count; $i++) {
        $v = if ($i -lt $r.Count) { $r[$i] } else { '' }
        $fill = if ($i -eq $estadoIdx -and $colors.ContainsKey($v)) { $colors[$v] } else { '' }
        [void]$sb.Append((Cell $v $fill ($i -eq $estadoIdx) $widths[$i]))
    }
    [void]$sb.Append('</w:tr>')
}
[void]$sb.Append('</w:tbl>')

$doc = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><w:document xmlns:w='http://schemas.openxmlformats.org/wordprocessingml/2006/main'><w:body>$($sb.ToString())<w:sectPr><w:pgSz w:w='16838' w:h='11906' w:orient='landscape'/><w:pgMar w:top='1000' w:right='1000' w:bottom='1000' w:left='1000' w:header='500' w:footer='500' w:gutter='0'/></w:sectPr></w:body></w:document>"
$ct = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Types xmlns='http://schemas.openxmlformats.org/package/2006/content-types'><Default Extension='rels' ContentType='application/vnd.openxmlformats-package.relationships+xml'/><Default Extension='xml' ContentType='application/xml'/><Override PartName='/word/document.xml' ContentType='application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'/></Types>"
$rels = "<?xml version='1.0' encoding='UTF-8' standalone='yes'?><Relationships xmlns='http://schemas.openxmlformats.org/package/2006/relationships'><Relationship Id='rId1' Type='http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument' Target='word/document.xml'/></Relationships>"

if (Test-Path $OutPath) {
    $OutPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($OutPath), [IO.Path]::GetFileNameWithoutExtension($OutPath) + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.docx')
}
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($OutPath)) | Out-Null
$zip = [IO.Compression.ZipFile]::Open($OutPath, 'Create')
$enc = New-Object Text.UTF8Encoding($false)
foreach ($p in @(@('[Content_Types].xml', $ct), @('_rels/.rels', $rels), @('word/document.xml', $doc))) {
    $w = New-Object IO.StreamWriter($zip.CreateEntry($p[0]).Open(), $enc)
    $w.Write($p[1]); $w.Close()
}
$zip.Dispose()
Write-Output "Generado: $OutPath ($($rows.Count) reglas)"
