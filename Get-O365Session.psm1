# Functions
# return CLI usage if missing arguments
function usage {
$err = @"
  Usage : 
    [Interactive Mode] :
      Get-O365Session `
        -samAccountName <samAccountName (required for interactive mode)> `
        -domain <O365 domain name>
    [Non-Interactive Mode] :
      Get-O365Session -credObject <credential object (required for non-interactive mode)>

"@
return $err
}

Function Get-O365Session {
  # cmdlet params
  param(
    [string]$samAccountName,
    [string]$domain,
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $credObject
  )


  # return usage statement if $samAccountName is $null
  # if (!($samAccountName -and $domain) -or (!$credObject) -or ($samAccountName) -eq "/?") { return $(usage) }
  if (!($samAccountName -and $domain) -and (!$credObject)) {
    return $(usage)
  }

  # get username i.e. first.last@domain.com
  # takes samAccountName and optionally a domain name
  # return concatinated version of samAccountName and domain name
  function getUserName {
    param(
      $username,
      $domain
    )
    # set domain default if Null or Empty
    if ($([string]::IsNullOrEmpty($domain))) {
      $domain = $dDomain;
    }
    # if $samAccountName contains @ then user has provided a full email address as user, no need to address
    # domain. This will return full address
    if ($username -match "@") {
      if ($username.split("@")[1]) {
        return "$username"
      } else {
        throw "Invalid email address supplied : $username"
      }
    } elseif ($([string]::IsNullOrEmpty($username))) {
      return $null
    } else {
      # returns concatenated string --> $samAccountName + @ + $domain
      return "$samAccountName@$domain"
    }
  }

  # setup PSSession
  if ($credObject.password -eq $null) {
    # set $credObject to NULL to prevent another popup for get credential
    $credObject = [System.Management.Automation.PSCredential]::Empty
    $O365Cred = Get-Credential $(getUserName $samAccountName $domain)
  } else {
    $O365Cred = $credObject
  }

  if ($O365Cred.Password.Length -eq 0) {
    throw "Missing Password"
  }

  $connectUri = "https://ps.outlook.com/powershell"
  # Create Session
  $O365Session = New-PSSession -Configuration Microsoft.Exchange -ConnectionUri $connectUri -Credential $O365Cred -Authentication Basic -AllowRedirection -WarningAction silentlyContinue

  # import Session Globally
  Import-Module (Import-PSSession $O365Session -AllowClobber -DisableNameChecking) -Global -WarningAction silentlyContinue
}

Export-ModuleMember Get-O365Session
