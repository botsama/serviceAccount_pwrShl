# Make user with local admin on local computer with no expire pass flag set.
# Check if user exists first, otherwise do not make user account changes.

$boxName = $env:COMPUTERNAME
$svcAccount = "yo_$boxName"
$passwordSet = 'turnUp4d3h$wol'
$pathToLog = Get-Location
$checkUserMade = net user $svcAccount 1> .\00_UserCheck.log 2>&1
$validateUser = Get-Content ".\00_UserCheck.log" | Out-String
# (Debug) Write-Host $validateUser

If ($validateUser -like '*The user name could not be found*') {
    Write-Host "User not present $svcAccount.  Creating service account on $boxName.";
    net user $svcAccount $passwordSet /add /expires:never 1> $pathToLog\"$boxName"_user01-Creation.log 2>&1;
    # create local user account from variable.

    wmic useraccount where "name='$svcAccount'" set passwordexpires=FALSE 1> $pathToLog\"$boxName"_user02-Perms.log 2>&1;
    # update password expires flag off to keep service password from expiring.

    net localgroup "Administrators" $svcAccount /add 1> $pathToLog\"$boxName"_user03-AddToDomainGroup.log 2>&1;
    # adds this user to local administrators group.
    # All 3 commands have a checksum log written to current folder\<Computername> with each step of the user process.
    }
    Else {Write-Host "Found User already present $svcAccount. No changes made on $boxName."
    }
