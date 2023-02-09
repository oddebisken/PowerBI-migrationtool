
############## BUILD THE FORM #####################
function Dialogbox {
    param(
        $title,
        $footer,
        $boxtype,
        $root,
        $listworkspace

    )
    set-location
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $icon = "$root\Data\Bokehlicia-Captiva-Cloud.ico"
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Power BI Migrationtool'
    $form.Size = New-Object System.Drawing.Size(600,500)
    $form.StartPosition = 'CenterScreen'
    $formIcon = New-Object system.drawing.icon ($icon)
    $form.Icon = $formIcon    


    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(100,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(175,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,10)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = $title
    $form.Controls.Add($label)

    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(10,240)
    $info.Size = New-Object System.Drawing.Size(280,20)
    $info.Text = $footer
    $form.Controls.Add($info)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(400,20)
    $listBox.Height = 200
    
    $file = (get-item "$root\Data\pt_Logo.png")
    $img = [System.Drawing.Image]::Fromfile($file);
    [System.Windows.Forms.Application]::EnableVisualStyles();
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(470,360)
    $pictureBox.Size = New-Object System.Drawing.Size($img.width,$img.Height)
    $pictureBox.Image = $img
    $Form.controls.add($pictureBox)


    $listBox.SelectionMode = $boxtype
    
    if ($listworkspace) {
        $listworkspace | %  -process {[void] $listBox.Items.Add($_.Name+" | "+$_.Id)}
    } 

    $form.Controls.Add($listBox)
    $form.Topmost = $true
    $result = $form.ShowDialog()
    $selectedItems = $listBox.SelectedItems
    return $selectedItems, $result
}



