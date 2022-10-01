#Te permite exportar en csv todos los users de una OU con su manager asociado, company y department
#RodrigoAltomonte


$output = @()
$filepath = "C:\Users\Raltomonte\Desktop\BlahBlah.csv"
$OUpath = "INSERT"
 
ForEach ($nameUser in ((Get-ADUser -Filter * -SearchBase $OUpath | Select-Object Name).name)){

    $user = Get-ADUser -Filter "Name -eq '$nameUser'" -Properties displayname,Department,Company,LastLogonDate | Select-object name,displayname,Department,Company,LastLogonDate
    $managerPath = (Get-ADUser -Filter "Name -eq '$nameUser'" -properties manager | Select-object manager).manager
    if ($managerPath -eq $null)
    {
        $manager = "Sin Lider Asignado"
    }
    else
    {
        $manager = (Get-ADUser -Filter * -SearchBase $managerPath -Properties displayname).displayname
    }

    $output += $user | Add-Member -MemberType NoteProperty -Name 'Lider' -Value $manager -PassThru
}
 
$output | Export-csv -NoTypeInformation -Path $filepath 
 