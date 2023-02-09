function FunctionName {
    param (
        $fullname,
        $email,
        $mobile,
        $companyname
    ) 

If($fullname.Text -eq ''){
    $valid1 = "Textbox cannot be empty"
} else {$valid1 = ""}# NotValid

If($email.Text -eq ''){
    $valid2 = "Textbox cannot be empty"
} else {$valid2 = ""}# NotValid 

If($mobile.Text -cmatch '^[A-Z][a-z]*$' -or $textBox3.Text -eq '' -or $textBox3.Text.Length -lt 8) # Valid
{
    $valid3 = "Please use 8 numbers, no space"
} else {$valid3 = ""}

If ($companyname.Text -cmatch '^[A-Z][0-9]*$' -or $textBox4.Text -eq '') {
    $valid4 = "Please use only lowercase, no symbols or numbers"

} else {$valid4 = ""}

return $valid1,$valid2,$valid3,$valid4


}
