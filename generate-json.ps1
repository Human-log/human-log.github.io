$postsPath = "C:\Users\Sampurna\matrix-blog\posts"
$jsonPath = "C:\Users\Sampurna\matrix-blog\posts.json"
$moodPath = "C:\Users\Sampurna\matrix-blog\mood-data.json"

$posts = @()
$moods = @()
Get-ChildItem "$postsPath\*.md" | ForEach-Object {
  $slug = $_.BaseName
  $c = Get-Content $_.FullName -Raw
  $title = ($slug -replace '[-_]', ' ') -replace '(^\w)|(\s\w)', { $_.Value.ToUpper() }
  if ($c -match '^#\s+(.+)') { $title = $Matches[1].Trim() }
  $date = ''
  if ($c -match '(\d{4}-\d{2}-\d{2})') { $date = $Matches[1] }
  $mood = ''
  if ($c -match 'Mood:\s*(\d+)/10') { $mood = $Matches[1] }
  $posts += [PSCustomObject]@{ slug = $slug; title = $title; date = $date; mood = $mood }
  if ($date -and $mood) { $moods += [PSCustomObject]@{ date = $date; mood = $mood; slug = $slug } }
}

$posts = $posts | Sort-Object date -Descending
$json = $posts | ConvertTo-Json
if ($json -notmatch '^\[') { $json = "[`r`n$json`r`n]" }
[System.IO.File]::WriteAllText($jsonPath, $json, [System.Text.UTF8Encoding]::new($false))

$moodJson = $moods | ConvertTo-Json
if ($moodJson -notmatch '^\[') { $moodJson = "[`r`n$moodJson`r`n]" }
[System.IO.File]::WriteAllText($moodPath, $moodJson, [System.Text.UTF8Encoding]::new($false))
