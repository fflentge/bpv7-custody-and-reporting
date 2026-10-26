[CmdletBinding()]
param(
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

# Decode output of native tools (kramdown-rfc, xml2rfc) as UTF-8 instead
# of the OEM code page, so non-ASCII characters survive the pipe.
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DraftDir = Join-Path $RepoRoot "drafts"
$BuildDir = Join-Path $RepoRoot "build"
$XmlDir = Join-Path $BuildDir "xml"
$TxtDir = Join-Path $BuildDir "txt"
$HtmlDir = Join-Path $BuildDir "html"

$Drafts = @(
    "draft-flentge-dtn-bundle-sequence-identification-00",
    "draft-flentge-dtn-bpv7-custody-transfer-00",
    "draft-flentge-dtn-compressed-status-reporting-00"
)

if ($Clean -and (Test-Path $BuildDir)) {
    Remove-Item $BuildDir -Recurse -Force
}

@($XmlDir, $TxtDir, $HtmlDir) | ForEach-Object {
    New-Item -ItemType Directory -Path $_ -Force | Out-Null
}

foreach ($Draft in $Drafts) {
    $Markdown = Join-Path $DraftDir "$Draft.md"
    $RawName = "$Draft-raw"
    $Xml = Join-Path $XmlDir "$Draft.xml"
    $Text = Join-Path $TxtDir "$Draft.txt"
    $Html = Join-Path $HtmlDir "$Draft.html"

    if (-not (Test-Path $Markdown)) {
        throw "Markdown source not found: $Markdown"
    }

    Write-Host "Generating RFCXML: $Draft" -ForegroundColor Cyan
    $RawXml = Join-Path $XmlDir "$RawName.xml"
    & kramdown-rfc --v3 $Markdown | Set-Content -Path $RawXml -Encoding utf8
    if ($LASTEXITCODE -ne 0) {
        throw "kramdown-rfc failed for $Markdown"
    }

    # Convert deprecated v2 <list> elements to RFCXML v3 and strip the
    # <?line?> source-location processing instructions, so the generated
    # XML passes the Datatracker's idnits3 check cleanly. Unlike
    # xml2rfc --preptool, --v2v3 adds no publication artifacts (prepTime
    # attribute, <boilerplate> element, xref format attributes) that
    # idnits3 rejects in submissions.
    & xml2rfc --v2v3 $RawXml --out $Xml
    if ($LASTEXITCODE -ne 0) {
        throw "xml2rfc v2v3 conversion failed for $RawXml"
    }
    Remove-Item $RawXml -Force
    $XmlContent = Get-Content $Xml -Raw -Encoding UTF8
    $XmlContent = $XmlContent -replace '<\?line\s+[-+]?[0-9]+\?>\r?\n?', ''
    Set-Content -Path $Xml -Value $XmlContent -Encoding utf8 -NoNewline

    Write-Host "Generating text: $Draft" -ForegroundColor Cyan
    & xml2rfc $Xml --text --out $Text
    if ($LASTEXITCODE -ne 0) {
        throw "xml2rfc text generation failed for $Xml"
    }

    Write-Host "Generating HTML: $Draft" -ForegroundColor Cyan
    & xml2rfc $Xml --html --out $Html
    if ($LASTEXITCODE -ne 0) {
        throw "xml2rfc HTML generation failed for $Xml"
    }
}

Write-Host ""
Write-Host "Note: kramdown-rfc may report an expected warning for the" `
    "explicit reference to the unpublished sequence-identification draft." `
    -ForegroundColor Yellow

Write-Host "Build completed successfully." -ForegroundColor Green
Write-Host "RFCXML: $XmlDir"
Write-Host "Text:   $TxtDir"
Write-Host "HTML:   $HtmlDir"
