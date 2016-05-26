# dot source all the psm1 files in repo root dir
Get-ChildItem ../ |`
  Where {
    $_.Name -like '*.psm1'
  } | `
  % {
    Import-Module $_.FullName
  }

# Check credObject return Function
Describe "Testing getCredentials function with credObject" {
  $tmpFile = "$env:temp\testing_credObject_$(Get-Random).txt"

  It "creates an encrypted password file" {
    # create a mock password file
    "super secret password" |`
      ConvertTo-SecureString -AsPlainText -Force |`
      ConvertFrom-SecureString |`
      Out-File -FilePath $tmpFile
    # test if file was created
    Test-Path $tmpFile | Should Be $True
  }

  # setup non-interactive mode $credObject
  $password = Get-Content -Path $tmpFile | ConvertTo-SecureString
  $cred = New-Object -TypeName PSCredential -ArgumentList 'testing.tester@example.com',$password
  $samAccountName = $null
  $domain = $null
  $result = $(getCredentials $samAccountName $domain $cred)

  It "make sure getCredentials function will return cred object (by checking type) when passed one" {
    $result | Should Be System.Management.Automation.PSCredential
  }

  It "makes sure UserName property value on credObject match the values we gave it" {
    $result.UserName | Should Be "testing.tester@example.com"
  }

  It "password not null" {
    $result | Should Not Be $null
  }

  It "deletes $tmpFile to cleanup our mess" {
    # delete file
    Try {
      Remove-Item $tmpFile -Force
    } Catch {
      throw $_
    }
    # test if it deleted
    Test-Path $tmpFile | Should Be $False
  }
}





