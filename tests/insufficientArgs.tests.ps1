# Check credObject return Function
Describe "Testing insufficient arguments passed to module" {

  # import main module manifest file
  Import-Module $PSScriptRoot\../Get-O365Session.psd1

  # mock of main module function using same logic to check args
  Mock Get-O365Session {
    param(
      [string]$samAccountName,
      [string]$domain,
      [System.Management.Automation.PSCredential]
      [System.Management.Automation.Credential()]
      $credObject
    )

    if (!($samAccountName -and $domain) -and (!$credObject)) {
      return $(usage)
    } else {
      return $True
    }
  }

  It "throw usage if no args are passed to module" {
    Get-O365Session | Should Be $(usage)
  }

  It "throw usage if only username is given to module...missing domain" {
    Get-O365Session -samAccountName "testing.tester" | Should Be $(usage)
  }

  It "throw usage if only domain is given to module...missing samAccountname" {
    Get-O365Session -domain "example.com" | Should Be $(usage)
  }
}
