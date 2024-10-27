#Requires -Version 7

function ConvertTo-SepaEpcStringHC(
    <#
        .SYNOPSIS
            Create a string for SEPA payments.

        .DESCRIPTION
            The created string can be used to generate a QR code that can be 
            scanned by a mobile device and will open the banking app to start a 
            SEPA wire transfer.

            The European Payments Council Quick Response Code guidelines define 
            the content of a QR code that can be used to initiate SEPA credit 
            transfer (SCT). It contains all the necessary information in clear 
            text. These QR code guidelines are used on many invoices and 
            payment requests in the countries that support it (Austria, 
            Belgium, Finland, Germany, The Netherlands) enabling tens of 
            millions to pay without requiring manual input leading to lower 
            error rates.

            The EPC guidelines are available from the EPC itself.

        .LINK
            https://en.wikipedia.org/wiki/EPC_QR_code

        .EXAMPLE
            # Module required to create the QR code from a string
            # https://github.com/TobiasPSP/Modules.QRCodeGenerator
            # - Install-Module -Name QRCodeGenerator -Scope CurrentUser -Force

            # Create the string that will be used in the QR code
            $params = @{
                Name                  = 'Red cross of Belgium' 
                BIC                   = 'BPOTBEB1' 
                IBAN                  = 'BE72000000001616'
                Amount                = 55.25 
                ReferenceUnstructured = 'Donation/23/02' 
                # Version               = '001' 
                # CharacterSet          = 1 
                # Purpose               = 'CHAR'
                # Information           = 'Test sample'
            }
            $qrCodeString = ConvertTo-SepaEpcStringHC @params

            # Create the QR code and save it in a png file
            $params = @{
                Text    = $qrCodeString 
                Width   = 80 
                Show    = $true
                OutPath = "$home/Downloads/myPaymentQrCode.png"
            }
            New-PSOneQRCodeText @params
    #>

    [CmdletBinding()]
    [Parameter(Mandatory)]
    [ValidateScript({ 
            if ($_.length -gt 27) { 
                throw "Max 27 characters allowed. Example value 'Belgian Red Cross'." 
            } 
            else { $true }
        })]
    [string]$Name,    
    [Parameter(Mandatory)]
    [ValidateScript({ 
            if ($_.length -gt 11) { 
                throw "Max 11 characters allowed. Example value 'BPOTBEB1'." 
            } 
            else { $true }
        })]
    [string]$BIC,
    [Parameter(Mandatory)]
    [ValidateScript({ 
            if ($_.length -gt 34) { 
                throw "Max 34 characters allowed. Example value 'BE72000000001616'." 
            }
            elseif (
                -not ($_ -match "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,}$")
            ) {
                throw "Invalid IBAN account number format. Example value 'BE72000000001616'."
            }
            else { $true }
        })]
    [string]$IBAN,    
    [Parameter(Mandatory)]
    [ValidateScript({ 
            if (-not (($_ -ge 0.01) -and ($_ -le 999999999.99))) { 
                throw "Amount needs to be at least 0.01 and max 999999999.99. Example value '50.25'." 
            } 
            else { $true }
        })]
    [decimal]$Amount,
    [ValidateScript({ 
            if ($_.length -gt 3) { 
                throw "Max 3 characters allowed. Example value 'BCD'." 
            } 
            else { $true }
        })]
    [string]$ServiceTag = 'BCD',
    [ValidateScript({ 
            if ($_.length -gt 3) { 
                throw "Max 3 characters allowed. Example value '001' or '002'." 
            } 
            else { $true }
        })]
    [string]$Version = '001',
    [ValidateSet(1, 2, 3, 4)]
    [int]$CharacterSet = 1,
    [ValidateScript({ 
            if ($_.length -gt 3) { 
                throw "Max 3 characters allowed. Example value 'SCT'." 
            } 
            else { $true }
        })]
    [string]$Identification = 'SCT',
    [ValidateScript({ 
            if ($_.length -gt 4) { 
                throw "Max 4 characters allowed. Example value 'CHAR'." 
            } 
            else { $true }
        })]
    [string]$Purpose,
    [ValidateScript({ 
            if ($_.length -gt 35) { 
                throw "Max 35 characters allowed. Example value 'INVOICE/NR2506'." 
            } 
            else { $true }
        })]
    [string]$ReferenceStructured,
    [ValidateScript({ 
            if ($_.length -gt 140) { 
                throw "Max 140 characters allowed. Example value 'Help war victims'." 
            } 
            else { $true }
        })]
    [string]$ReferenceUnstructured,
    [ValidateScript({ 
            if ($_.length -gt 70) { 
                throw "Max 70 characters allowed. Example value 'Do great things'." 
            } 
            else { $true }
        })]
    [string]$Information
) {
    $epcString = ''

    $officialFields = [ordered]@{
        '01' = $ServiceTag
        '02' = $Version
        '03' = $CharacterSet
        '04' = $Identification
        '05' = $BIC
        '06' = $Name
        '07' = $IBAN
        '08' = ('EUR{0:0.00}' -f $Amount)
        '09' = $Purpose
        '10' = $ReferenceStructured
        '11' = $ReferenceUnstructured
        '12' = $Information
    }
    
    $officialFields.GetEnumerator().ForEach(
        { 
            $epcString += "{0}`n" -f $(
                if ($_.value) { ([string]$_.value).Trim() }
            ) 
        } 
    )
    
    $epcStringResult = $($epcString.Trim())

    Write-Verbose "Created EPC string:`r`n$epcStringResult"

    $epcStringResult
}

Export-ModuleMember -Function * -Alias *