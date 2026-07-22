Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$postsDir = "C:\Users\Sampurna\matrix-blog\posts"
$git = "C:\Program Files\Git\bin\git.exe"
$repoDir = "C:\Users\Sampurna\matrix-blog"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Human.Log - New Journal Entry"
$form.Size = New-Object System.Drawing.Size(500, 520)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0a0a0a"
$form.ForeColor = "#00ff41"
$form.Font = New-Object System.Drawing.Font("Courier New", 10)

function AddLabel($text, $y) {
  $lbl = New-Object System.Windows.Forms.Label
  $lbl.Text = $text
  $lbl.Location = New-Object System.Drawing.Point(20, $y)
  $lbl.Size = New-Object System.Drawing.Size(440, 22)
  $lbl.ForeColor = "#00ff41"
  $form.Controls.Add($lbl)
}

function AddTextBox($y, $w, $h) {
  $tb = New-Object System.Windows.Forms.TextBox
  $tb.Location = New-Object System.Drawing.Point(20, $y)
  $tb.Size = New-Object System.Drawing.Size($w, $h)
  $tb.BackColor = "#1a1a1a"
  $tb.ForeColor = "#00ff41"
  $tb.BorderStyle = "FixedSingle"
  $form.Controls.Add($tb)
  return $tb
}

$y = 20

AddLabel "> Date" $y
$dateInput = AddTextBox $y 140 22
$dateInput.Text = Get-Date -Format "yyyy-MM-dd"
$y += 35

AddLabel "> Mood (1-10)" $y
$moodBox = AddTextBox $y 80 22
$moodBox.Text = "7"
$y += 35

AddLabel "> Entry Title" $y
$titleInput = AddTextBox $y 440 22
$y += 35

AddLabel "> Wake up time" $y
$wakeInput = AddTextBox $y 140 22
$wakeInput.Text = Get-Date -Format "HH:mm"
$y += 35

AddLabel "> Sleep time" $y
$sleepInput = AddTextBox $y 140 22
$y += 35

AddLabel "> About My Day" $y
$y += 25
$aboutBox = New-Object System.Windows.Forms.TextBox
$aboutBox.Location = New-Object System.Drawing.Point(20, $y)
$aboutBox.Size = New-Object System.Drawing.Size(440, 180)
$aboutBox.Multiline = $true
$aboutBox.ScrollBars = "Vertical"
$aboutBox.BackColor = "#1a1a1a"
$aboutBox.ForeColor = "#00ff41"
$aboutBox.BorderStyle = "FixedSingle"
$aboutBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$form.Controls.Add($aboutBox)
$y += 195

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, $y)
$statusLabel.Size = New-Object System.Drawing.Size(440, 22)
$statusLabel.ForeColor = "#008f11"
$form.Controls.Add($statusLabel)
$y += 30

$saveBtn = New-Object System.Windows.Forms.Button
$saveBtn.Text = "[ SAVE ]"
$saveBtn.Location = New-Object System.Drawing.Point(20, $y)
$saveBtn.Size = New-Object System.Drawing.Size(120, 30)
$saveBtn.BackColor = "#1a1a1a"
$saveBtn.ForeColor = "#00ff41"
$saveBtn.FlatStyle = "Flat"
$saveBtn.Add_Click({
  $title = $titleInput.Text
  if (-not $title) { $title = "Journal Entry - " + $dateInput.Text }
  $slug = $title.ToLower() -replace '[^a-z0-9]+', '-' -replace '-+', '-'
  $slug = $slug.Trim('-')
  $slug = $dateInput.Text + "-" + $slug

  $md = "# " + $title + "`r`n"
  $md += "Date: " + $dateInput.Text + "`r`n"
  $md += "Mood: " + $moodBox.Text + "/10`r`n"
  if ($wakeInput.Text) { $md += "Wake: " + $wakeInput.Text + "`r`n" }
  if ($sleepInput.Text) { $md += "Sleep: " + $sleepInput.Text + "`r`n" }
  $md += "`r`n"
  if ($aboutBox.Text) { $md += $aboutBox.Text + "`r`n`r`n" }

  $filePath = Join-Path $postsDir "$slug.md"
  [System.IO.File]::WriteAllText($filePath, $md, [Text.UTF8Encoding]::new($false))
  $statusLabel.Text = "Saved: $slug.md"
  $saveBtn.Enabled = $false
  $publishBtn.Enabled = $true
})
$form.Controls.Add($saveBtn)

$publishBtn = New-Object System.Windows.Forms.Button
$publishBtn.Text = "[ PUBLISH ]"
$publishBtn.Location = New-Object System.Drawing.Point(160, $y)
$publishBtn.Size = New-Object System.Drawing.Size(120, 30)
$publishBtn.BackColor = "#1a1a1a"
$publishBtn.ForeColor = "#ffcc00"
$publishBtn.FlatStyle = "Flat"
$publishBtn.Enabled = $false
$publishBtn.Add_Click({
  $publishBtn.Text = "PUBLISHING..."
  $publishBtn.Enabled = $false
  & "C:\Users\Sampurna\matrix-blog\generate-json.ps1"
  & $git -C $repoDir add .
  & $git -C $repoDir commit -m "new post"
  & $git -C $repoDir push
  $statusLabel.Text = "Published to GitHub!"
})
$form.Controls.Add($publishBtn)

$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "[ CLOSE ]"
$closeBtn.Location = New-Object System.Drawing.Point(300, $y)
$closeBtn.Size = New-Object System.Drawing.Size(100, 30)
$closeBtn.BackColor = "#1a1a1a"
$closeBtn.ForeColor = "#008f11"
$closeBtn.FlatStyle = "Flat"
$closeBtn.Add_Click({ $form.Close() })
$form.Controls.Add($closeBtn)

$form.ShowDialog()
