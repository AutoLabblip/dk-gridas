param(
  [string]$MonthFolder = "DEC2025",
  [string]$Title = "DK GRIDAS - Marketing Report",
  [string]$LastUpdated = "{{LAST_UPDATED}}",
  [string]$OutputFile = "index.html"
)

$root = Split-Path -Parent $PSCommandPath
$imagesDir = Join-Path $root $MonthFolder
$templatePath = Join-Path $root "report-template.html"
$outputPath = Join-Path $root $OutputFile

if (-not (Test-Path $imagesDir)) {
  throw "Month folder not found: $imagesDir"
}
if (-not (Test-Path $templatePath)) {
  throw "Template not found: $templatePath"
}

$imageExts = @(".jpg", ".jpeg", ".png", ".gif", ".webp")
$images = Get-ChildItem -Path $imagesDir -File |
  Where-Object { $imageExts -contains $_.Extension.ToLower() } |
  Sort-Object Name

if ($images.Count -gt 0) {
  $cards = foreach ($img in $images) {
    $rel = "./$MonthFolder/$($img.Name)"
    "<div class='card'><img src='$rel' alt='$($img.BaseName)' /></div>"
  }
  $imagesHtml = ($cards -join "`r`n      ")
} else {
  $imagesHtml = "<div class='card empty'>No images found in $MonthFolder.</div>"
}

$html = Get-Content -Raw $templatePath
$html = $html.Replace("{{TITLE}}", $Title)
$html = $html.Replace("{{MONTH}}", $MonthFolder)
$html = $html.Replace("{{LAST_UPDATED}}", $LastUpdated)
$html = $html.Replace("{{IMAGES}}", $imagesHtml)

Set-Content -Path $outputPath -Value $html
Write-Host "Generated $outputPath from $MonthFolder"
