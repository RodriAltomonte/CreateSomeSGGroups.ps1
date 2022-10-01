
#Obtener users a traves de OU

$OUpath = "INSERT"
$ExportPath = 'C:\Users\Raltomonte\Desktop\users_x.csv'
Get-ADUser -Filter * -SearchBase $OUpath | Select-object Name | Export-Csv -NoType $ExportPath

$OUpath = "INSERT"
$ExportPath = 'C:\Users\Raltomonte\Desktop\users_z.csv'
Get-ADUser -Filter * -SearchBase $OUpath | Select-object Name | Export-Csv -NoType $ExportPath



Get-ADUser -Filter * -SearchBase $OUpath  -Properties EmailAddress,DisplayName, samaccountname | Select-object DistinguishedName,Name,UserPrincipalName, EmailAddress | Export-Csv -NoType $ExportPath




#Obtener mail de users a traves del nombre

$OUpath = "INSERT"
$ExportPath = 'C:\Users\Raltomonte\Desktop\users_Mail.csv'
$ImportPath = 'C:\Users\Raltomonte\Desktop\users-Z-X.txt'
foreach($line in Get-Content $ImportPath) {
    Get-ADUser -LDAPFilter "(Name=$line)" -SearchBase $OUpath  -Properties EmailAddress,DisplayName, samaccountname | Select-object Name, EmailAddress | Export-Csv $ExportPath  -append -notypeinformation -encoding "unicode"
}

#Ejemplo para un unico user

Get-ADUser -LDAPFilter "(Name=b0426)" -SearchBase $OUpath  -Properties EmailAddress,DisplayName, samaccountname | Select-object DistinguishedName,Name,UserPrincipalName, EmailAddress | Export-Csv -NoType $ExportPath

Get-AdUser -LDAPFilter "(Name=b0426)" -SearchBase "INSERT" -Properties *
