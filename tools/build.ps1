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
    $Xml = Join-Path $XmlDir "$Draft.xml"
    $Text = Join-Path $TxtDir "$Draft.txt"
    $Html = Join-Path $HtmlDir "$Draft.html"

    if (-not (Test-Path $Markdown)) {
        throw "Markdown source not found: $Markdown"
    }

    Write-Host "Generating RFCXML: $Draft" -ForegroundColor Cyan
    & kramdown-rfc --v3 $Markdown | Set-Content -Path $Xml -Encoding utf8
    if ($LASTEXITCODE -ne 0) {
        throw "kramdown-rfc failed for $Markdown"
    }

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
