$port = 8080
$postsDir = "C:\Users\Sampurna\matrix-blog\posts"
$publishBat = "C:\Users\Sampurna\matrix-blog\publish.bat"
$htmlFile = "C:\Users\Sampurna\matrix-blog\journal.html"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Journal server running at http://localhost:$port/"
Write-Host "Close this window to stop the server."
Start-Process "http://localhost:$port/"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $request = $context.Request
  $response = $context.Response

  if ($request.HttpMethod -eq 'GET' -and $request.Url.LocalPath -eq '/') {
    $html = Get-Content $htmlFile -Raw
    $html = $html -replace '</head>', '<script>const API_URL="http://localhost:' + $port + '";</script></head>'
    $buffer = [Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentType = 'text/html; charset=utf-8'
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
  }
  elseif ($request.HttpMethod -eq 'POST' -and $request.Url.LocalPath -eq '/save') {
    $reader = New-Object IO.StreamReader($request.InputStream)
    $body = $reader.ReadToEnd()
    $params = [Web.HttpUtility]::ParseQueryString($body)
    $slug = $params['slug']
    $content = $params['content']
    $filePath = Join-Path $postsDir "$slug.md"
    [IO.File]::WriteAllText($filePath, $content, [Text.UTF8Encoding]::new($false))
    & "C:\Program Files\Git\bin\git.exe" -C "C:\Users\Sampurna\matrix-blog" add "posts/$slug.md" 2>$null

    $reply = '{"ok":true,"file":"' + $slug + '.md"}'
    $buffer = [Text.Encoding]::UTF8.GetBytes($reply)
    $response.ContentType = 'application/json'
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
  }
  elseif ($request.HttpMethod -eq 'POST' -and $request.Url.LocalPath -eq '/publish') {
    & "C:\Users\Sampurna\matrix-blog\generate-json.ps1"
    & cmd.exe /c "`"$publishBat`""
    $reply = '{"ok":true,"published":true}'
    $buffer = [Text.Encoding]::UTF8.GetBytes($reply)
    $response.ContentType = 'application/json'
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
  }
  else {
    $response.StatusCode = 404
  }
  $response.Close()
}
