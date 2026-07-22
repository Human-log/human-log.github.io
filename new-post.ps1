Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$postsDir = "C:\Users\Sampurna\matrix-blog\posts"
$repoDir = "C:\Users\Sampurna\matrix-blog"
$git = "C:\Program Files\Git\bin\git.exe"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Human.Log - New Journal Entry"
$form.Size = New-Object Drawing.Size(500, 520)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0a0a0a"
$form.ForeColor = "#00ff41"
$form.Font = New-Object Drawing.Font("Courier New", 10)

Function AddLabel($text, $y, $size) {
  $lbl = New-Object System.Windows.Forms.Label
  $lbl.Text = $text
  $lbl.Location = New-Object Drawing.Point(20, $y)
  $lbl.Size = New-Object Drawing.Size(440, 20)
  $lbl.ForeColor = "#00ff41"
  $form.Controls.Add($lbl)
  return $lbl
}

Function AddInput($y, $w, $h) {
  $tb = New-Object System.Windows.Forms.TextBox
  $tb.Location = New-Object Drawing.Point(20, $y)
  $tb.Size = New-Object Drawing.Size($w, $h)
  $tb.BackColor = "#1a1a1a"
  $tb.ForeColor = "#00ff41"
  $tb.BorderStyle = "FixedSingle"
  $tb.Font = New-Object Drawing.Font("Courier New", 10)
  $form.Controls.Add($tb)
  return $tb
}

Function AddDropdown($y, $items) {
  $dd = New-Object System.Windows.Forms.ComboBox
  $dd.Location = New-Object Drawing.Point(140, $y)
  $dd.Size = New-Object Drawing.Size(80, 20)
  $dd.BackColor = "#1a1a1a"
  $dd.ForeColor = "#00ff41"
  $dd.Items.AddRange($items)
  $dd.SelectedIndex = 6
  $form.Controls.Add($dd)
  return $dd
}

$y = 20

AddLabel "> Date", $y, 20
$dateInput = AddInput($y, 140, 20)
$dateInput.Text = Get-Date -Format "yyyy-MM-dd"
$y += 35

AddLabel "> Mood (1-10)", $y, 20
$moodDropdown = AddDropdown($y, @(1,2,3,4,5,6,7,8,9,10))
$y += 35

AddLabel "> Entry Title", $y, 20
$titleInput = AddInput($y, 440, 20)
$y += 35

AddLabel "> Wake up time", $y, 20
$wakeInput = AddInput($y, 140, 20)
$wakeInput.Text = Get-Date -Format "HH:mm"
$y += 35

AddLabel "> Sleep time", $y, 20
$sleepInput = AddInput($y, 140, 20)
$y += 35

AddLabel "> About My Day", $y, 20
$y += 25
$aboutBox = New-Object System.Windows.Forms.TextBox
$aboutBox.Location = New-Object Drawing.Point(20, $y)
$aboutBox.Size = New-Object Drawing.Size(440, 180)
$aboutBox.Multiline = $true
$aboutBox.ScrollBars = "Vertical"
$aboutBox.BackColor = "#1a1a1a"
$aboutBox.ForeColor = "#00ff41"
$aboutBox.BorderStyle = "FixedSingle"
$aboutBox.Font = New-Object Drawing.Font("Courier New", 10)
$form.Controls.Add($aboutBox)
$y += 195

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object Drawing.Point(20, $y)
$statusLabel.Size = New-Object Drawing.Size(440, 20)
$statusLabel.ForeColor = "#008f11"
$form.Controls.Add($statusLabel)
$y += 30

$saveBtn = New-Object System.Windows.Forms.Button
$saveBtn.Text = "[ SAVE ]"
$saveBtn.Location = New-Object Drawing.Point(20, $y)
$saveBtn.Size = New-Object Drawing.Size(120, 30)
$saveBtn.BackColor = "#1a1a1a"
$saveBtn.ForeColor = "#00ff41"
$saveBtn.FlatStyle = "Flat"
$saveBtn.Font = New-Object Drawing.Font("Courier New", 10)
$saveBtn.Add_Click({
  $title = $titleInput.Text
  if (-not $title) { $title = "Journal Entry - " + $dateInput.Text }
  $slug = $title.ToLower() -replace '[^a-z0-9]+', '-' -replace '-+', '-' -trim '-'
  $slug = $dateInput.Text + "-" + $slug

  $md = "# " + $title + "`n"
  $md += "Date: " + $dateInput.Text + "`n"
  $md += "Mood: " + $moodDropdown.Text + "/10`n"
  if ($wakeInput.Text) { $md += "Wake: " + $wakeInput.Text + "`n" }
  if ($sleepInput.Text) { $md += "Sleep: " + $sleepInput.Text + "`n" }
  $md += "`n"
  if ($aboutBox.Text) { $md += $aboutBox.Text + "`n`n" }

  $filePath = Join-Path $postsDir "$slug.md"
  [System.IO.File]::WriteAllText($filePath, $md, [Text.UTF8Encoding]::new($false))
  $statusLabel.Text = "Saved: $slug.md"
  $saveBtn.Enabled = $false
  $publishBtn.Enabled = $true
})
$form.Controls.Add($saveBtn)

$publishBtn = New-Object System.Windows.Forms.Button
$publishBtn.Text = "[ PUBLISH ]"
$publishBtn.Location = New-Object Drawing.Point(160, $y)
$publishBtn.Size = New-Object Drawing.Size(120, 30)
$publishBtn.BackColor = "#1a1a1a"
$publishBtn.ForeColor = "#ffcc00"
$publishBtn.FlatStyle = "Flat"
$publishBtn.Font = New-Object Drawing.Font("Courier New", 10)
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
$closeBtn.Location = New-Object Drawing.Point(300, $y)
$closeBtn.Size = New-Object Drawing.Size(100, 30)
$closeBtn.BackColor = "#1a1a1a"
$closeBtn.ForeColor = "#008f11"
$closeBtn.FlatStyle = "Flat"
$closeBtn.Font = New-Object Drawing.Font("Courier New", 10)
$closeBtn.Add_Click({ $form.Close() })
$form.Controls.Add($closeBtn)

$form.ShowDialog()
