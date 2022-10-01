$groups = @('Domain Admins','Domain Users','INSERT GROUPS')
$output = @()
$filepath = "C:\INSERT PATH\unParDeGrupitos.csv"
 
ForEach ($group in $groups) {
    
    $users = Get-ADGroupMember -Identity $group | Get-ADUser -Properties name,displayName | select name,displayname
    
    ForEach ($user in $users){
 
        $output += $user | Add-Member -MemberType NoteProperty -Name 'Grupo' -Value $group -PassThru
 
    }
}
 
$output | Export-csv -NoTypeInformation -Path $filepath 