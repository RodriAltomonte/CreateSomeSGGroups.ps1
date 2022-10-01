# Shared Mailbox
Function ConvertToSharedMailbox {

    clear
    write-host "Convert User to Shared MailBox"

    # Variables
    $SMPreHandle = read-host "Enter the User"
    $SMHandle = ($SMPreHandle)
    $SMGivenName = ($SMPreHandle)
    $SMLastName = "sm"
    $SMDisplayName = ($SMProject)
    $SMDescription = ("Shared Mailbox para "+$SMProject)
    $SMOffice = "NOADGAL"
    $SMAlias = ($SMPreHandle)
    $SMMail = ($SMAlias+"@bancodelsol.com")
    $SMOwner = read-host "Enter the Shared Mailbox Owner"
    $SMInfo = ("Owner: "+$SMOwner)
    $SMOU = "INSERT OU"

    # Verifies if account exist
    [string]$VrfUser = (Get-AdUser -LDAPFilter "(sAMAccountName=$SMHandle)" -SearchBase "DC=bdsol,DC=com,DC=ar" -ErrorAction SilentlyContinue).sAMAccountName
    If($VrfUser -eq $SMHandle) {

        Start-Sleep 3

        # Add default security groups
        Add-ADGroupMember -identity "Shared Mailboxes" -members $SMHandle
        Write-Host "Added $SMHandle in security group " -ForegroundColor green
        write-host "Shared Mailboxes" -ForegroundColor yellow
        Start-Sleep 1

        #Set default Primary Group
        $Primary = Get-ADGroup "Shared Mailboxes" -properties @("primaryGroupToken")
        Set-ADUser $SMHandle -Replace @{primaryGroupID=$Primary.primaryGroupToken}
        Remove-ADGroupMember -identity "Domain Users" -members $SMHandle -Confirm:$false

        # Enable Mail account
        write-host ""
        Write-Host "Enabling the user mailbox"
        Start-Sleep 5
        #Enable-RemoteMailbox -Identity $SMHandle -alias $SMAlias -remoteroutingaddress ($SMAlias+"@bdsolcomar.mail.onmicrosoft.com")
        #Set-RemoteMailbox -Identity $SMHandle -customattribute15 MS365 -EmailAddressPolicyEnabled $false -PrimarySmtpAddress $SMMail
        #Set-RemoteMailbox -Identity $SMHandle -Type Shared
        Write-Host "Created the Mail Account $SMMail" -ForegroundColor green
        write-host ""
        
    }
    
    write-host ""
    Write-Host "Press any key to continue ..." -ForegroundColor yellow
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}

# ---------------------------------------------------------------------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------------------------------------------------------------------

# Main
write-host "Iniciando creacion de Grupos.."

# Login
$Handle = "INSERT USER"
$Password = read-host "Enter your PASSWORD" -assecurestring
$DomainNetBIOS = "BDSol"
$DomainFQDN = (Get-ADDomain $DomainNetBIOS).DNSRoot 
$UserName = $DomainNetBIOS+"\"+$Handle
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($UserName,$Password)

# Connecting with Domain Controller
$DC = "INSERT DCG"
$adcps = New-PsSession -Computername $DC -Credential $Cred
$null = Invoke-Command -Command {Import-Module ActiveDirectory} -Session $adcps
$null = Import-PSSession $adcps -Module ActiveDirectory -AllowClobber

TestUserCredentials $Handle $Password $DomainNetBIOS $DomainFQDN $UserName
ConvertToSharedMailbox

# Disconnect AD Central
Remove-PSSession $adcps
write-host "Toque una tecla para finalizar.."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Exit
#The End

# ---------------------------------------------------------------------------------------------------------------------------------------

