Get-O365Session
=================

The purpose of this module is to make it easier to obtain a `Powershell` Session with Office365 for Administative tasks. It does *REQUIRE* an administrative account to Office365 in order to work properly.

Once session is aquired you will have access to all of the Office365 remote management cmdlets, such as `Get-Mailbox` `Get-DistributionList` `Get-MailboxPermissions` etc. There are over 500 cmdlets that will be downloaded into your `PSSESSION` that will be available.

install
=================

Clone the repo into a directory contained in your `PSMODULES` path.

_Note : After adding to path you may need to restart your powershell session for the module to become available._

usage
=====

There are 2 ways to use this module. You can either pass in `samaccountname` and `domain` argument and be prompted for your password. Or you can supply an already crafted `PSCredential` Object. If you pass in a credential object you will *NOT* be prompted. This will enable to ability to automate the session creation.

###Option 1 - Interactive (will prompt you for Password)


```
Get-O365Session -samAccountName testing.tester -domain example.com
```

OR (shorthand with unnamed arguments)


```
Get-O365Session testing.tester example.com
```

`samAccountName` refers to your logon name (the left side of the `@` in your email address)
`domain` refers to the domain after the `@` in your email address


###Option 2 - Non-Interactive (will *NOT* prompt for anything)

```
$password = Get-Content -Path .\password.txt | ConvertTo-SecureString
$cred = New-Object -TypeName PSCredential -ArgumentList 'testing.tester@example.com', $password

Get-O365Session -credObject $cred
```

_Note : Don't worry about storing passwords in plain text. You can follow below code to create a txt file that encrypts your password and stores on disk._

#####Create Encrypted file to use in Non-interactive mode

```
$credential = Get-Credential
# you will be prompted for username and password...please type in the correct info

$credential.Password | ConvertFrom-SecureString | Out-File -FilePath "c:\password.txt"
```

Now you can use `c:\password.txt` in the above example section. Just supply the correct path in the `$password` variable declaration section


tests
======

Test Require Pester. See https://github.com/pester/Pester for details.

To run the test just run below command from inside the repo directory :

```
Invoke-Pester
```

Pester will find the tests directory and run all of the tests.

license
=======

MIT
