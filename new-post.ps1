Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$postsDir = "D:\matrix-blog\posts"
$git = "C:\Program Files\Git\bin\git.exe"
$repoDir = "D:\matrix-blog"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Human.Log - New Journal Entry"
$form.Size = New-Object System.Drawing.Size(540, 580)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#000000"
$form.ForeColor = "#00ff41"

function AddLabel($text, $x, $y, $w) {
  $lbl = New-Object System.Windows.Forms.Label
  $lbl.Text = $text
  $lbl.Location = New-Object System.Drawing.Point($x, $y)
  $lbl.Size = New-Object System.Drawing.Size($w, 24)
  $lbl.ForeColor = "#00ff41"
  $lbl.Font = New-Object System.Drawing.Font("Consolas", 10)
  $form.Controls.Add($lbl)
}

$y = 25

AddLabel "> Date" 20 $y 100
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = New-Object System.Drawing.Point(130, $y)
$datePicker.Size = New-Object System.Drawing.Size(140, 24)
$datePicker.Format = "Short"
$datePicker.BackColor = "#111111"
$datePicker.ForeColor = "#00ff41"
$datePicker.CalendarForeColor = "#00ff41"
$datePicker.CalendarBackColor = "#111111"
$datePicker.CalendarTitleBackColor = "#111111"
$datePicker.CalendarTitleForeColor = "#00ff41"
$datePicker.CalendarTrailingForeColor = "#008f11"
$form.Controls.Add($datePicker)
$y += 35

AddLabel "> Mood (1-10)" 20 $y 100
$moodUpDown = New-Object System.Windows.Forms.NumericUpDown
$moodUpDown.Location = New-Object System.Drawing.Point(130, $y)
$moodUpDown.Size = New-Object System.Drawing.Size(60, 24)
$moodUpDown.Minimum = 1
$moodUpDown.Maximum = 10
$moodUpDown.Value = 7
$moodUpDown.BackColor = "#111111"
$moodUpDown.ForeColor = "#00ff41"
$moodUpDown.BorderStyle = "FixedSingle"
$form.Controls.Add($moodUpDown)
$y += 35

AddLabel "> Entry Title" 20 $y 100
$titleInput = New-Object System.Windows.Forms.TextBox
$titleInput.Location = New-Object System.Drawing.Point(130, $y)
$titleInput.Size = New-Object System.Drawing.Size(360, 24)
$titleInput.BackColor = "#111111"
$titleInput.ForeColor = "#00ff41"
$titleInput.BorderStyle = "FixedSingle"
$titleInput.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($titleInput)
$y += 35

AddLabel "> Wake up" 20 $y 100
$wakePicker = New-Object System.Windows.Forms.DateTimePicker
$wakePicker.Location = New-Object System.Drawing.Point(130, $y)
$wakePicker.Size = New-Object System.Drawing.Size(100, 24)
$wakePicker.Format = "Time"
$wakePicker.ShowUpDown = $true
$wakePicker.BackColor = "#111111"
$wakePicker.ForeColor = "#00ff41"
$form.Controls.Add($wakePicker)
$y += 35

AddLabel "> Sleep" 20 $y 100
$sleepPicker = New-Object System.Windows.Forms.DateTimePicker
$sleepPicker.Location = New-Object System.Drawing.Point(130, $y)
$sleepPicker.Size = New-Object System.Drawing.Size(100, 24)
$sleepPicker.Format = "Time"
$sleepPicker.ShowUpDown = $true
$sleepPicker.BackColor = "#111111"
$sleepPicker.ForeColor = "#00ff41"
$form.Controls.Add($sleepPicker)
$y += 35

AddLabel "> About My Day" 20 $y 200
$y += 28
$aboutBox = New-Object System.Windows.Forms.TextBox
$aboutBox.Location = New-Object System.Drawing.Point(20, $y)
$aboutBox.Size = New-Object System.Drawing.Size(480, 200)
$aboutBox.Multiline = $true
$aboutBox.ScrollBars = "Vertical"
$aboutBox.BackColor = "#111111"
$aboutBox.ForeColor = "#00ff41"
$aboutBox.BorderStyle = "FixedSingle"
$aboutBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$form.Controls.Add($aboutBox)
$y += 215

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, $y)
$statusLabel.Size = New-Object System.Drawing.Size(480, 24)
$statusLabel.ForeColor = "#008f11"
$statusLabel.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($statusLabel)
$y += 30

function MakeButton($text, $x, $color) {
  $btn = New-Object System.Windows.Forms.Button
  $btn.Text = $text
  $btn.Location = New-Object System.Drawing.Point($x, $y)
  $btn.Size = New-Object System.Drawing.Size(130, 32)
  $btn.BackColor = "#111111"
  $btn.ForeColor = $color
  $btn.FlatStyle = "Flat"
  $btn.FlatAppearance.BorderColor = $color
  $btn.Font = New-Object System.Drawing.Font("Consolas", 10)
  $form.Controls.Add($btn)
  return $btn
}

$saveBtn = MakeButton "[ SAVE ]" 20 "#00ff41"
$saveBtn.Add_Click({
  $title = $titleInput.Text
  if (-not $title) { $title = "Journal Entry - " + $datePicker.Value.ToString("yyyy-MM-dd") }
  $slug = $title.ToLower() -replace '[^a-z0-9]+', '-' -replace '-+', '-'
  $slug = $slug.Trim('-')
  $slug = $datePicker.Value.ToString("yyyy-MM-dd") + "-" + $slug

  $md = "# " + $title + "`r`n"
  $md += "Date: " + $datePicker.Value.ToString("yyyy-MM-dd") + "`r`n"
  $md += "Mood: " + $moodUpDown.Value + "/10`r`n"
  $md += "Wake: " + $wakePicker.Value.ToString("HH:mm") + "`r`n"
  $md += "Sleep: " + $sleepPicker.Value.ToString("HH:mm") + "`r`n"
  $md += "`r`n"
  if ($aboutBox.Text) { $md += $aboutBox.Text + "`r`n`r`n" }

  $filePath = Join-Path $postsDir "$slug.md"
  [System.IO.File]::WriteAllText($filePath, $md, [Text.UTF8Encoding]::new($false))
  $statusLabel.Text = "Saved: $slug.md"
  $saveBtn.Enabled = $false
  $publishBtn.Enabled = $true
})

$publishBtn = MakeButton "[ PUBLISH ]" 170 "#ffcc00"
$publishBtn.Enabled = $false
$publishBtn.Add_Click({
  $publishBtn.Text = "PUBLISHING..."
  $publishBtn.Enabled = $false
  & "D:\matrix-blog\generate-json.ps1"
  & $git -C $repoDir add .
  & $git -C $repoDir commit -m "new post"
  & $git -C $repoDir push
  $statusLabel.Text = "Published to GitHub!"
})

$closeBtn = MakeButton "[ CLOSE ]" 320 "#666666"
$closeBtn.Add_Click({ $form.Close() })

$form.ShowDialog()
