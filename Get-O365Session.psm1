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

# get username i.e. username@domain.com
# takes samAccountName and a domain name
# return concatinated version of samAccountName and domain name
Function getUserName {
  param(
    $username,
    $domain
  )

  # if $samAccountName contains @ then user has provided a full email address as user, no need to address
  # domain. This will return full address
  if ($username -match "@") {
      # user input a full email so just return the full address
      return $username
  } elseif ($([string]::IsNullOrEmpty($username)) -or $username -eq " ") {
    # input was null so return $null
    return $null
  } else {
    # returns concatenated string --> $samAccountName + @ + $domain
    # if domain is blank then will just return $username@
    return "$username@$domain"
  }
}

# get credentials
Function getCredentials {
  param(
    [string]$samAccountName,
    [string]$domain,
    $credObject
  )

  # decide what mode to use interactive or non-interactive based on args
  if ($credObject.password -eq $null) {
    # set $credObject to NULL to prevent another popup for get credential
    $credObject = [System.Management.Automation.PSCredential]::Empty
    return Get-Credential $(getUserName $samAccountName $domain)
  } else {
    return $credObject
  }
}

# main module function
Function Get-O365Session {
  # cmdlet params
  param(
    [string]$samAccountName,
    [string]$domain,
    [System.Management.Automation.PSCredential]
    $credObject
  )

  # return usage statement if args are missing/incomplete
  if (!($samAccountName -and $domain) -and (!$credObject)) {
    return $(usage)
  }

  # setup
  $connectUri = "https://ps.outlook.com/powershell"
  $O365Cred = getCredentials $samAccountName $domain $credObject

  # throw if password is blank
  if ($O365Cred.Password.Length -eq 0) {
    throw "Missing Password"
  }

  # Create Session
  $O365Session = New-PSSession `
    -Configuration Microsoft.Exchange `
    -ConnectionUri $connectUri `
    -Credential $O365Cred `
    -Authentication Basic `
    -AllowRedirection `
    -WarningAction silentlyContinue

  # import Session Globally
  Import-Module (Import-PSSession $O365Session -AllowClobber -DisableNameChecking) `
    -Global `
    -WarningAction silentlyContinue
}

Export-ModuleMember -Function *
