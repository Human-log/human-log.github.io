$jsonPath = "C:\Users\Sampurna\matrix-blog\posts.json"
$posts = @()
Get-ChildItem "C:\Users\Sampurna\matrix-blog\posts\*.md" | ForEach-Object {
  $slug = $_.BaseName
  $c = Get-Content $_.FullName -Raw
  $title = ($slug -replace '[-_]', ' ') -replace '(^\w)|(\s\w)', { $_.Value.ToUpper() }
  if ($c -match '^#\s+(.+)') { $title = $Matches[1].Trim() }
  $date = ''
  if ($c -match '(\d{4}-\d{2}-\d{2})') { $date = $Matches[1] }
  $posts += [PSCustomObject]@{ slug = $slug; title = $title; date = $date }
}
$posts = $posts | Sort-Object date -Descending
$json = $posts | ConvertTo-Json
if ($json -notmatch '^\[') { $json = "[`r`n$json`r`n]" }
[System.IO.File]::WriteAllText($jsonPath, $json, [System.Text.UTF8Encoding]::new($false))
