
############## BUILD THE FORM #####################
function dialogbox_multi {
    param(
        $allsubs,
        $title,
        $title2,
        $title3,
        $footer,
        $root,
        $boxtype

    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $icon = "$root\Data\Bokehlicia-Captiva-Cloud.ico"
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Azure Kontroll'
    $form.Size = New-Object System.Drawing.Size(1100,350)
    $form.StartPosition = 'CenterScreen'
    $formIcon = New-Object system.drawing.icon ($icon)
    $form.Icon = $formIcon    

    
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(25,270)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)
    
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(100,270)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)
    
    #title 1
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = $title
    $form.Controls.Add($label)

    #listbox 1
    $listBox = New-Object System.Windows.Forms.Listbox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(320,20)
    $listBox.SelectionMode = 'MultiExtended'
    #Single Select End
    
    #title 2
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(370,20)
    $label2.Size = New-Object System.Drawing.Size(280,20)
    $label2.Text = $title2
    $form.Controls.Add($label2)
    
    #listbox 2
    $listBox2 = New-Object System.Windows.Forms.Listbox
    $listBox2.Location = New-Object System.Drawing.Point(370,40)
    $listBox2.Size = New-Object System.Drawing.Size(320,20)
    $listBox2.SelectionMode = 'MultiExtended'
    
    #title 3 
    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(730,20)
    $label3.Size = New-Object System.Drawing.Size(300,20)
    $label3.Text = $title3
    $form.Controls.Add($label3)
    #listbox 3
    $listBox3 = New-Object System.Windows.Forms.Listbox
    $listBox3.Location = New-Object System.Drawing.Point(730,40)
    $listBox3.Size = New-Object System.Drawing.Size(320,20)
    $listBox3.SelectionMode = 'MultiExtended'

    #footer
    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point(380,200)
    $info.Size = New-Object System.Drawing.Size(320,60)
    $info.Text = $footer
    $form.Controls.Add($info)
    
    $file = (get-item "$root\Data\azk_Logo.jpg")
    $img = [System.Drawing.Image]::Fromfile($file);
    
    [System.Windows.Forms.Application]::EnableVisualStyles();
    
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(980,220)
    $pictureBox.Size = New-Object System.Drawing.Size($img.width,$img.Height)
    $pictureBox.Image = $img
    $Form.controls.add($pictureBox)
    #Multiple Item Select End
    
    
    ForEach($sub in $allsubs){
      $allsubs | %  -process {[void] $listBox.Items.Add($sub)}
      $allsubs | %  -process {[void] $listBox2.Items.Add($sub)}
      $allsubs | %  -process {[void] $listBox3.Items.Add($sub)}
    }

    $listBox.Height = 140
    $listBox2.Height = 140
    $listBox3.Height = 140
    $form.Controls.Add($listBox)
    $form.Controls.Add($listBox2)
    $form.Controls.Add($listBox3)
    $form.Topmost = $true
    
    
    $form.Controls.Add($listBox)
    $form.Controls.Add($listBox2)
    $form.Controls.Add($listBox3)
    $form.Topmost = $true
    
    $result = $form.ShowDialog()

    $selectedDevsub = $listBox.SelectedItems
    $selectedtestsub = $listBox2.SelectedItems
    $selectedprodsub = $listBox3.SelectedItems

    return $selectedDevsub,$selectedtestsub,$selectedprodsub, $result
}

