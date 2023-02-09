
############## BUILD THE FORM #####################
function Dialogbox_info {
    param(
        $root
    )
    
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing 
    $icon = "$root\Data\Bokehlicia-Captiva-Cloud.ico"
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'PowerBI Migrationtool'
    $form.Size = New-Object System.Drawing.Size(800,500)
    $form.StartPosition = 'CenterScreen'
    $formIcon = New-Object system.drawing.icon ($icon)
    $form.Icon = $formIcon    

    #Header
    $header = New-Object System.Windows.Forms.Label
    $header.Location = New-Object System.Drawing.Point(10,10)
    $header.Size = New-Object System.Drawing.Size(750,100)
    $header.Text = "Service principal login info"
    $header.BackColor = 'LightBlue'
    $header.font = New-Object System.Drawing.Font("Calibri",18,[System.Drawing.FontStyle]::Bold)
    $header.Padding = "10,10,10,10"
    $form.Controls.Add($header)
        #Subheader
        $Subheader = New-Object System.Windows.Forms.Label
        $Subheader.Location = New-Object System.Drawing.Point(10,70)
        $Subheader.Size = New-Object System.Drawing.Size(440,40)
        $Subheader.Text = "Please provide information about your service principals.`n They need powerbi administrator and workspace/read.all"
        $Subheader.BackColor = 'LightBlue'
        $Subheader.Padding = "14,0,0,0"
        $form.Controls.Add($Subheader)
        $Subheader.BringToFront()
    
    #Input textbox and label for TenantID
    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(10,130) #from 120 -> 140
    $label1.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 150
    $label1.Text = "Enter Source TenantID"
    $form.Controls.Add($label1) 

    $TenantID_Source = New-Object System.Windows.Forms.TextBox
    $TenantID_Source.Location = New-Object System.Drawing.Point(10,150) #from 150 -> 170
    $TenantID_Source.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 180
    $form.Controls.Add($TenantID_Source) 

    #Input textbox and label for ClientID
    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10,190) #from 180 -> 200
    $label2.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 210
    $label2.Text = "Enter Source ClientID"
    $form.Controls.Add($label2)    
  
    $clientid_Source = New-Object System.Windows.Forms.TextBox
    $clientid_Source.Location = New-Object System.Drawing.Point(10,210) #from 210 -> 220
    $clientid_Source.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 230
    $form.Controls.Add($clientid_Source) 

    #Input textbox and label for clientsecret
    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10,250) #from 240 -> 260
    $label3.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 270
    $label3.Text = "Enter Source Client Secret"
    $form.Controls.Add($label3)    

    $clientsecret_Source = New-Object System.Windows.Forms.MaskedTextBox
    $clientsecret_Source.PasswordChar = '*'
    $clientsecret_Source.Location = New-Object System.Drawing.Point(10,270) #from 270 -> 290
    $clientsecret_Source.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 300
    $form.Controls.Add($clientsecret_Source) 
 
    #Input textbox and label for Destination TenantID
    $label4 = New-Object System.Windows.Forms.Label
    $label4.Location = New-Object System.Drawing.Point(400,130) #from 120 -> 140
    $label4.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 150
    $label4.Text = "Enter Destination TenantID"
    $form.Controls.Add($label4) 

    $TenantID_Destination = New-Object System.Windows.Forms.TextBox
    $TenantID_Destination.Location = New-Object System.Drawing.Point(400,150) #from 150 -> 170
    $TenantID_Destination.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 180
    $form.Controls.Add($TenantID_Destination) 

    #Input textbox and label for Destination ClientID
    $label5 = New-Object System.Windows.Forms.Label
    $label5.Location = New-Object System.Drawing.Point(400,190) #from 180 -> 200
    $label5.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 210
    $label5.Text = "Enter Destination ClientID"
    $form.Controls.Add($label5)    
  
    $clientid_Destination = New-Object System.Windows.Forms.TextBox
    $clientid_Destination.Location = New-Object System.Drawing.Point(400,210) #from 210 -> 220
    $clientid_Destination.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 230
    $form.Controls.Add($clientid_Destination) 

    #Input textbox and label for Destination clientsecret
    $label6 = New-Object System.Windows.Forms.Label
    $label6.Location = New-Object System.Drawing.Point(400,250) #from 240 -> 260
    $label6.Size = New-Object System.Drawing.Size(280,20) #add gap 10 -> 270
    $label6.Text = "Enter Destination Client Secret"
    $form.Controls.Add($label6)    

    $clientsecret_Destination = New-Object System.Windows.Forms.MaskedTextBox
    $clientsecret_Destination.PasswordChar = '*'
    $clientsecret_Destination.Location = New-Object System.Drawing.Point(400,270) #from 270 -> 290
    $clientsecret_Destination.Size = New-Object System.Drawing.Size(350,20)  #add gap 10 -> 300
    $form.Controls.Add($clientsecret_Destination) 


    $file = (get-item "$root\Data\pt_Logo.png")
    $img = [System.Drawing.Image]::Fromfile($file);
    [System.Windows.Forms.Application]::EnableVisualStyles();
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(540,350)
    $pictureBox.Size = New-Object System.Drawing.Size($img.width,$img.Height)
    $pictureBox.Image = $img
    $Form.controls.add($pictureBox)
    $pictureBox.BringToFront()

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(175,400)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,400)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    # Add Validation Control
    $ErrorProvider = New-Object System.Windows.Forms.ErrorProvider

    # set the forms    
    $form.Add_Shown({$form.Activate()})
    $form.Topmost = $true
    $result = $form.ShowDialog()

    # return the values
    $TenantID_Source = $TenantID_Source.Text
    $clientid_Source = $clientid_Source.Text
    $TenantID_Destination = $TenantID_Destination.Text
    $clientid_Destination = $clientid_Destination.Text
    $clientsecret_Source = $clientsecret_Source.Text
    $clientsecret_Destination = $clientsecret_Destination.Text
    return $TenantID_Source, $clientid_Source, $clientsecret_Source, $TenantID_Destination, $clientid_Destination, $clientsecret_Destination, $result
}



