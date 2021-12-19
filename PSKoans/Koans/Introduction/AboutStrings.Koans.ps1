﻿using module PSKoans
[Koan(Position = 104)]
param()
<#
    Strings

    Strings in PowerShell come in two flavours: expandable strings, and string
    literals. Expandable strings in PowerShell are created using double quotes,
    while string literals are created with single quotes.

    Expandable strings in PowerShell can evaluate expressions or variables
    mid-string in order to dynamically insert values into a preset string, like
    a sort of impromptu template string.
#>
Describe 'Strings' {

    It 'is a simple string of text' {
        'Abcd' | Should -Be 'string'
    }

    Context 'Literal Strings' {

        It 'assumes everything is literal' {
            $var = 'Some things you must take literally'
            'Some things you must take literally' | Should -Be $var
        }

        It 'can contain special characters' {
            # 'Special' is just a title.
            $complexVar = 'They interpret these characters literally: $ ` $()'
            'They interpret these characters literally: $ ` $()' | Should -Be $complexVar
        }

        It 'can contain quotation marks' {
            $Quotes = 'This creates only one set of ''quotation marks'' in the string.'

            # Single quotes are easier to work with in double-quoted strings.
            "This creates only one set of 'quotation marks' in the string." | Should -Be $Quotes
        }
    }

    Context 'Evaluated Strings' {

        It 'can expand variables' {
            $var = 'apple'
            'My favorite fruit is apple' | Should -Be "My favorite fruit is $var"
        }

        It 'can do a simple expansion' {
            'Your home directory is: C:\Users\nunyo' | Should -Be "Your home directory is: $HOME"
        }

        It 'handles other ways of doing the same thing' {
            # Strings can handle entire subexpressions being inserted as well!
            $String = "Your home folder is: $(Get-Item -Path $HOME)"
            'Your home folder is: C:\Users\nunyo' | Should -Be $String
        }

        It 'will expand variables that do not exist' {
            <#
                If a string contains a variable that has not been created,
                PowerShell will still try to expand the value. A variable that
                doesn't exist or has a null value will simply disappear when it
                is expanded.

                This could be the result of a typing mistake.
            #>
            $String = "PowerShell's home folder is: $PSHome"
            "PowerShell's home folder is: C:\Windows\System32\WindowsPowerShell\v1.0" | Should -Be $String
        }

        It 'can get confused about :' {
            <#
                In PowerShell, a colon (:) is used to define a scope or provider
                path for a variable. For example, the Environment provider uses
                the syntax $env:SomeVariableName, which refers to an environment
                variable named 'SomeVariableName'. Environment variables are
                initially set by the operating system and usually passed to
                child processes, offering a limited way for processes to
                communicate in a limited way.

                When : is part of a string, PowerShell will try and expand a
                variable in that scope or from that provider.
            #>

            $Number = 1
            $String = "$Number:Get shopping"
            'shopping' | Should -Be $String
        }

        It 'can use curly braces to mark the variable name' {
            <#
                Variables followed by : or adjacent to other characters normally
                included in a variable name can be referenced by enclosing the
                variable name with curly braces like so: ${varName}
            #>

            $Number = 1
            $String = "${Number}:Get shopping"
            '1:Get shopping' | Should -Be $String
        }

        It 'can escape special characters with backticks' {
            $LetterA = 'Apple'
            $String = "`$LetterA contains $LetterA."

            '$LetterA contains Apple.' | Should -Be $String
        }

        It 'can escape quotation marks' {
            $String = "This is a `"string`" value."
            $AlternateString = "This is a ""string"" value."

            # A mirror image, a familiar pattern, reflected in the glass.
            $Results = @(
                'This is a "string" value.'
                'This is a "string" value.'
            )
            $Results | Should -Be @($String, $AlternateString)
        }

        It 'can insert special characters with escape sequences' {
            <#
                All text strings in PowerShell are actually just a series of
                character values. Each of these values has a specific number
                assigned in the [char] type that represents that letter, number,
                or other character.

                .NET uses UTF16 encoding for [char] and [string] values.
                However, with most common letters, numbers, and symbols, the
                assigned [char] values are identical to the ASCII values.

                ASCII is an older standard encoding for text, but you can still
                use all those values as-is with [char] and get back what you'd
                expect thanks to the design of the UTF16 encoding. An extended
                ASCII code table is available at: https://www.ascii-code.com/
            #>
            $ExpectedValue = [char] 9

            <#
                If you're not sure what character you're after, consult the
                ASCII code table above.

                Get-Help about_Special_Characters will list the escape sequence
                you can use to create the right character with PowerShell's
                native string escape sequences.
            #>
            $ActualValue = "`"

            $ActualValue | Should -Be $ExpectedValue
        }
    }

    Context 'String Concatenation' {

        It 'adds strings together' {
            # Two become one.
            $String1 = 'This string'
            $String2 = 'is cool.'

            $String1 + ' ' + $String2 | Should -Be 'This string is cool.'
        }

        It 'can be done more easily' {
            # Water mixes seamlessly with itself.
            $String1 = 'This string'
            $String2 = 'is cool.'

            "$String1 $String2" | Should -Be 'This string is cool.'
        }
    }

    Context 'Substrings' {

        It 'lets you select portions of a string' {
            # Few things require the entirety of the library.
            $String = 'At the very top!'

            <#
                The [string].Substring() method has a few variants, or
                "overloads." The most common overloads are:

                string Substring(int startIndex)
                string Substring(int startIndex, int length)

                In other words:
                - Both variants return a string.
                - One variant needs two index references, where to start and
                    stop in selecting the substring.
                - The other only requires a starting index, and goes until the
                    end of the original string.
            #>
            'At the' | Should -Be $String.Substring(0, 6)
            'very top!' | Should -Be $String.Substring(7)
        }
    }

    Context 'Here-Strings' {
        <#
            Here-strings are a fairly common programming concept, but have some
            additional quirks in PowerShell that bear mention. They start with
            the sequence @' or @" and end with the matching reverse "@ or '@
            sequence.

            The terminating sequence MUST be at the start of the line, or they
            will be ignored, and the string will not terminate correctly.
        #>
        It 'can be a literal string' {
            $LiteralString = @'
            Hullo!
'@ # This terminating sequence must be at the start of the line.

            # "Empty" space, too, is a thing of substance for some.
            '            Hullo!' | Should -Be $LiteralString
        }

        It 'can be an evaluated string' {
            # The key is in the patterns.
            $Number = 10

            # Indentation sometimes gets a bit disrupted around here-strings.
            $String = @"
I am number 10
"@

            'I am number 10' | Should -Be $String
        }

        It 'interprets all quotation marks literally' {
            $AllYourQuotes = @"
All things that are not 'evaluated' are "recognised" as characters.
"@
            'All things that are not 'evaluated' are "recognised" as characters.' | Should -Be $AllYourQuotes
        }
    }

    Context 'Arrays and Strings' {

        It 'can be inserted into a string' {
            <#
                Arrays converted to string will display each member separated by
                a space by default.
            #>
            $array = @(
                'Hello'
                'world'
            )
            'Hello world' | Should -Be "$array"
        }

        It 'can be joined with a different string by setting the OFS variable' {
            <#
                The $OFS variable, short for "Output Field Separator," defines
                the separator used to join an array when it is converted to a
                string.

                By default, the OFS variable is unset, and a single space is
                used as the separator.
            #>

            $OFS = '... '
            $array = @(
                'Hello'
                'world'
            )
            'Hello... world' | Should -Be "$array"

            # Removing the created OFS variable, the default will be restored.
            Remove-Variable -Name OFS -Force
        }
    }
}
