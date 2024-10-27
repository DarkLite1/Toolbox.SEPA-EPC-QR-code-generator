#Requires -Version 7
#Requires -Modules Pester

BeforeDiscovery {
    $testModule = $PSCommandPath.Replace('.Tests.ps1', '.psm1')
    $testModuleName = $testModule.Split('\')[-1].TrimEnd('.psm1')

    Remove-Module $testModuleName -Force -Verbose:$false -EA Ignore
    Import-Module $testModule -Force -Verbose:$false
}
Describe 'ConvertTo-SepaEpcStringHC' {
    BeforeAll {
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
        $actual = ConvertTo-SepaEpcStringHC @params
    }
    It 'create a single string' {
        $actual | Should -HaveCount 1
    }
    It 'use the default values' {
        $actual | Should -Be 'BCD
001
1
SCT
BPOTBEB1
Red cross of Belgium
BE72000000001616
EUR55.25


Donation/23/02'
    }
    It 'use given values' {
        $params = @{
            ServiceTag            = 'ABC'
            Identification        = 'DEF'
            Name                  = 'Name of the beneficiary' 
            BIC                   = 'ABCDEFG' 
            IBAN                  = 'BE72000000161612'
            Amount                = 999999999.99
            ReferenceStructured   = 'ReferenceStructured'
            ReferenceUnstructured = 'ReferenceUnstructured/23/02' 
            Version               = '002' 
            CharacterSet          = 4
            Purpose               = 'CHAR'
            Information           = 'Information'
        }
        $actual = ConvertTo-SepaEpcStringHC @params

        $actual | Should -be 'ABC
002
4
DEF
ABCDEFG
Name of the beneficiary
BE72000000161612
EUR999999999.99
CHAR
ReferenceStructured
ReferenceUnstructured/23/02
Information'
    }
}