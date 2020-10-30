<#	
check zscaler state on PCs.
#>


Function Set-RegistryKey
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True, HelpMessage = "Please Enter Registry Item Path", Position = 1)]
		$Path,
		[Parameter(Mandatory = $True, HelpMessage = "Please Enter Registry Item Name", Position = 2)]
		$Name,
		[Parameter(Mandatory = $True, HelpMessage = "Please Enter Registry Property Item Value", Position = 3)]
		$Value,
		[Parameter(Mandatory = $False, HelpMessage = "Please Enter Registry Property Type", Position = 4)]
		$PropertyType = "DWORD"
	)
	
	# If path does not exist, create it
	If ((Test-Path $Path) -eq $False)
	{
		
		$newItem = New-Item -Path $Path -Force
		
	}
	
	# Update registry value, create it if does not exist (DWORD is default)
	$itemProperty = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
	If ($itemProperty -ne $null)
	{
		$itemProperty = Set-ItemProperty -Path $Path -Name $Name -Value $Value
	}
	Else
	{
		
		$itemProperty = New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType
	}
	
}

Set-RegistryKey -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 1

$url = Invoke-WebRequest "http://ip.zscaler.com/"
$checkzscaler = ($URL.ParsedHtml.getElementsByTagName('div') | where{ $_.className -eq 'headline' }).innertext

if ($checkzscaler -eq "The request received from you did not have an XFF header, so you are quite likely not going through the Zscaler proxy service.")
{
	Write-Output "Zscaler-Turned Off"
    exit 1
}
else
{
	Write-Output "Compliant"
	exit 0 
}
