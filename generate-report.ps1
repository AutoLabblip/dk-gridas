param(
  [string]$MonthFolder = "DEC2025",
  [string]$Title = "DK GRIDAS - Marketing Report",
  [string]$LastUpdated = "{{LAST_UPDATED}}",
  [string]$OutputFile = "index.html",
  [string]$DataFile = "report-data.json"
)

$root = Split-Path -Parent $PSCommandPath
$imagesDir = Join-Path $root $MonthFolder
$templatePath = Join-Path $root "report-template.html"
$outputPath = Join-Path $root $OutputFile
$dataPath = Join-Path $root $DataFile

if (-not (Test-Path $imagesDir)) {
  throw "Month folder not found: $imagesDir"
}
if (-not (Test-Path $templatePath)) {
  throw "Template not found: $templatePath"
}

$dataSection = "<div class='card empty'>No extracted data provided.</div>"
if (Test-Path $dataPath) {
  $data = Get-Content -Raw $dataPath | ConvertFrom-Json
  $keyStatsHtml = ""
  foreach ($item in $data.key_stats) {
    $keyStatsHtml += "<div class='stat'><div class='label'>$($item.label)</div><div class='value'>$($item.value)</div><div class='label'>$($item.note)</div></div>"
  }
  $sourcesHtml = "<ul>" + (($data.top_sources | ForEach-Object { "<li>$($_.label): $($_.value)</li>" }) -join "") + "</ul>"
  $pagesHtml = "<ul>" + (($data.top_pages | ForEach-Object { "<li>$($_.label): $($_.value)</li>" }) -join "") + "</ul>"
  $engagementHtml = "<ul>" + (($data.engagement | ForEach-Object { "<li>$($_.label): $($_.value)</li>" }) -join "") + "</ul>"
  $buttonsHtml = "<ul>" + (($data.buttons | ForEach-Object { "<li>$($_.label): $($_.value)</li>" }) -join "") + "</ul>"
  $dataSection = @"
<div class='section'>
  <h2>Extracted stats</h2>
  <div class='stats-grid'>$keyStatsHtml</div>
  <div class='stats-grid' style='margin-top:12px'>
    <div class='list'><div class='label'>Top traffic sources</div>$sourcesHtml</div>
    <div class='list'><div class='label'>Most visited pages</div>$pagesHtml</div>
    <div class='list'><div class='label'>Engagement</div>$engagementHtml</div>
    <div class='list'><div class='label'>Most clicked buttons</div>$buttonsHtml</div>
  </div>
</div>
"@
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
$html = $html.Replace("{{DATA_SECTION}}", $dataSection)

Set-Content -Path $outputPath -Value $html
Write-Host "Generated $outputPath from $MonthFolder"
