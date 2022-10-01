
# Test User Credentials Function 
Function TestUserCredentials {
    param($Handle,$Password,$DomainNetBIOS,$DomainFQDN,$UserName)
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password) 
    $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 

    Write-Host "`n" 
    Write-Host "Checking Credentials for $UserName" -BackgroundColor Black -ForegroundColor White 
    Write-Host "`n" 

    If ($Handle -eq $Null){ 
        Write-Host "Please enter your username and try again" -BackgroundColor Black -ForegroundColor Yellow 
        Rerun 
        Break 
    } 
    $DomainObj = "LDAP://" + $DomainFQDN 
    $DomainBind = New-Object System.DirectoryServices.DirectoryEntry($DomainObj,$Handle,$PlainPassword) 
    $DomainName = $DomainBind.distinguishedName 
     
    If ($DomainName -eq $Null) { 
        Write-Host "Domain $DomainFQDN was found: True" -BackgroundColor Black -ForegroundColor Green  
        $UserExist = Get-ADUser -Server $DomainFQDN -Properties LockedOut -Filter {sAMAccountName -eq $Handle} 
        If ($UserExist -eq $Null) { 
            Write-Host "Error: Username $Handle does not exist in $DomainFQDN Domain." -BackgroundColor Black -ForegroundColor Red
            write-host ""
            write-host "This console will be closed"
            write-host ""
            Write-Host "Press any key to continue ..." -ForegroundColor yellow
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Clear
            Break 
        } 
        Else {    
            Write-Host "User exists in the domain: True" -BackgroundColor Black -ForegroundColor Green 
            If ($UserExist.Enabled -eq "True") { 
                Write-Host "User Enabled: "$UserExist.Enabled -BackgroundColor Black -ForegroundColor Green 
            } 
            Else { 
                Write-Host "User Enabled: "$UserExist.Enabled -BackgroundColor Black -ForegroundColor Red 
                Write-Host "Enable the user account in Active Directory, Then check again" -BackgroundColor Black -ForegroundColor Red 
                write-host ""
                write-host "This console will be closed"
                write-host ""
                Write-Host "Press any key to continue ..." -ForegroundColor yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Clear
                Break 
            } 
            If ($UserExist.LockedOut -eq "True") { 
                Write-Host "User Locked: " $UserExist.LockedOut -BackgroundColor Black -ForegroundColor Red 
                Write-Host "Unlock the User Account in Active Directory, Then check again..." -BackgroundColor Black -ForegroundColor Red 
                write-host ""
                write-host "This console will be closed"
                write-host ""
                Write-Host "Press any key to continue ..." -ForegroundColor yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Clear
                Break 
            } 
            Else { 
                Write-Host "User Locked: " $UserExist.LockedOut -BackgroundColor Black -ForegroundColor Green 
            } 
        } 
        
        Write-Host "Authentication failed for $UserName with the provided password." -BackgroundColor Black -ForegroundColor Red 
        Write-Host "Please confirm the password, and try again..." -BackgroundColor Black -ForegroundColor Red 
        write-host ""
        write-host "This console will be closed"
        write-host ""
        Write-Host "Press any key to continue ..." -ForegroundColor yellow
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear
        Break 
    }
    
    Else { 
        Write-Host "SUCCESS: The account $UserName successfully authenticated against the domain: $DomainFQDN" -BackgroundColor Black -ForegroundColor Green
    }    
}

# CreateGroups Function 
Function CreateGroups {

    Write-Host "Creacion de Grupos ..."
    write-host ""
    $file_Groups = Get-Content  C:\Users\Raltomonte\Desktop\Groups.txt
    foreach ($SGHandle in $file_Groups)
    {
        # Verifies if group exist
        Write-Host " ----------- Grupo: $SGHandle ----------- "

        [string]$VrfUser = (Get-AdGroup -LDAPFilter "(sAMAccountName=$SGHandle)" -SearchBase "DC=bdsol,DC=com,DC=ar" -ErrorAction SilentlyContinue).sAMAccountName
        If($VrfUser -eq $SGHandle) {
            write-host ""
            write-host "El Grupo $SGHandle Ya Existe XD" -ForegroundColor yellow

        }else{

            $CharArray =$SGHandle.Split("-")
            $name = $CharArray[1]
            $DW = "W"
            $DR = "R"
            $SGOU = "INSERT"
            

            If($CharArray[2] -eq $DW) {
                # El grupo no existe y es DATAWRITER
                $desc = "Sharepoint - Negocio - $name - Writer"
                New-ADGroup -Name $SGHandle -SamAccountName $SGHandle -GroupCategory Security -GroupScope Global -DisplayName $SGHandle -Path $SGOU -Description $desc -OtherAttributes @{'extensionAttribute15'="MS365"}
                write-host "Se Creo el Grupo --> $SGHandle" -ForegroundColor green
                write-host ""

            }elseif ($CharArray[2] -eq $DR) {
                # El grupo no existe y es DATAWRITER
                $desc = "Sharepoint - Negocio - $name - Reader"
                New-ADGroup -Name $SGHandle -SamAccountName $SGHandle -GroupCategory Security -GroupScope Global -DisplayName $SGHandle -Path $SGOU -Description $desc -OtherAttributes @{'extensionAttribute15'="MS365"}
                write-host "Se Creo el Grupo --> $SGHandle" -ForegroundColor green
                write-host ""

            }else{
                Write-Host "Error del formato de Acceso .." -ForegroundColor red -BackgroundColor white
            }

        }
    }

}

# ---------------------------------------------------------------------------------------------------------------------------------------

# Main

write-host "Iniciando creacion de Grupos.."

# Login
$Handle = "INSERT user"
$Password = read-host "Enter your PASSWORD" -assecurestring
$DomainNetBIOS = "INSERT"
$DomainFQDN = (Get-ADDomain $DomainNetBIOS).DNSRoot 
$UserName = $DomainNetBIOS+"\"+$Handle
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($UserName,$Password)

# Connecting with Domain Controller
$DC = "INSERT"
$adcps = New-PsSession -Computername $DC -Credential $Cred
$null = Invoke-Command -Command {Import-Module ActiveDirectory} -Session $adcps
$null = Import-PSSession $adcps -Module ActiveDirectory -AllowClobber

TestUserCredentials $Handle $Password $DomainNetBIOS $DomainFQDN $UserName
CreateGroups

# Disconnect AD Central
Remove-PSSession $adcps
write-host "Toque una tecla para finalizar.."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Exit
#The End

# ---------------------------------------------------------------------------------------------------------------------------------------

