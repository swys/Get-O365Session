# import all modules in repo root dir
Get-ChildItem ../ |`
  Where {
    $_.Name -like '*.psm1'
  } | `
  % {
    Import-Module $_.FullName
  }

# Check credObject return Function
Describe "Testing getUserName function" {

  It "if given a full email address will just return the full email back" {
    getUserName "testing.tester@example.com" | Should Be "testing.tester@example.com"
  }

  It "if given username and domain in 2 seperate args it will return full email address" {
    getUserName "testing.tester" "example.com" | Should Be "testing.tester@example.com"
  }

  It "if given only a username and no domain it will not return a valid email address" {
    $(getUserName "testing.tester").split("@")[1] -eq '' | Should Be $True
  }
}





