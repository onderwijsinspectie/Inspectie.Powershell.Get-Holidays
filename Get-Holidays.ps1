#--------------------------------------------------------------------------------------------------------------------------------------------
# Dit script berekent de schoolvakanties voor het Vlaamse onderwijs
#
# author: Jeroen Brussich <jeroen.brussich@onderwijsinspectie.be>
#--------------------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------------------
# Vanaf welk schooljaar wil je de vakantiedagen beginnen te berekenen?
#
# Een schooljaar begint op 1 september (bv: 2000)
# De eerste vakantie die het script teruggeeft, zal dus de herfstvakantie (voor het jaar 2000) zijn
#--------------------------------------------------------------------------------------------------------------------------------------------

    $schooljaar = 2023

#--------------------------------------------------------------------------------------------------------------------------------------------
# Voor hoeveel schooljaren ver wil je de vakantiedagen berekenen?
#
# minimum: 1
#--------------------------------------------------------------------------------------------------------------------------------------------

    $aantalSchooljaren = 3

#--------------------------------------------------------------------------------------------------------------------------------------------
# Toon brugdag na Hemelvaart?
#
# Volgens https://onderwijs.vlaanderen.be/nl/schoolvakanties maken alle niveau's de brugdag na Hemelvaart, behalve DKO.
# Met deze instelling kan je bepalen of je die brugdag al dan niet wil tonen
#--------------------------------------------------------------------------------------------------------------------------------------------

    $toonBrugdagNaHemelvaart = $true

#--------------------------------------------------------------------------------------------------------------------------------------------
# In welk formaat wil je de datums genereren?
#
# Inspiratie nodig? https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings?redirectedfrom=MSDN
#--------------------------------------------------------------------------------------------------------------------------------------------

    $dateFormat = "dd-MM-yyyy" 

#--------------------------------------------------------------------------------------------------------------------------------------------
# Waar slaan we het bestand met vakantie dagen op?
#
# Voorstel: in dezelfde map waarin dit script zich bevindt
#--------------------------------------------------------------------------------------------------------------------------------------------

    $outFile = "$($PSScriptRoot)\vakantiedagen.csv"

#--------------------------------------------------------------------------------------------------------------------------------------------
# We vetrekken altijd vanuit een vers bestand
#
# Wil je de nieuwe data toch gewoon toevoegen aan het reeds bestaande bestand, comment onderstaande lijn dan uit
# Opgelet! Het script controleert niet op dubbels. Je kan met andere woorden de vakantiedagen van 2000 -tig keer blijven toevoegen
#--------------------------------------------------------------------------------------------------------------------------------------------

    if ( (Test-Path -Path $outFile) ) { Remove-Item -Path $outFile -Force -Confirm:$false }

#--------------------------------------------------------------------------------------------------------------------------------------------
# Start Script
#--------------------------------------------------------------------------------------------------------------------------------------------

    $DebugPreference = 'Continue'

    # Sanity Check

    if ( $schooljaar -notmatch "\d{4}" ) { throw "Het schooljaar ($schooljaar) lijkt niet het juiste formaat te hebben." }

    if ( $aantalSchooljaren -isnot [int] ) { throw "aantalSchooljaren ($aantalSchooljaren) moet numerieke waarden bevatten." }

    #--------------------------------------------------------------------------------------------------------------------------------------------
    # De vakanties
    #--------------------------------------------------------------------------------------------------------------------------------------------

    for ($j = 0; $j -lt $aantalSchooljaren; $j++)
    {

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Herstvakantie
        #
        # De herfstvakantie begint in Vlaanderen op de maandag van de week waarin de 1e kalenderdag van de maand november valt en duurt 7 dagen.
        # Indien de 1e kalender dag van november op een zondag valt, dan start de herfstvakantie op de 2e kalender dag van november.
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Herfstvakantie $schooljaar"

        $november1th = [DateTime]"$schooljaar-11-1"

        # Ga op zoek naar de eerste maandag van de huidige maand
        # Valt 1 november bijvoorbeeld op een vrijdag (5) dan moeten we 4 dagen terug om op maandag uit te komen.
        # - 5 + 1 = -4
        $herfstvakantieStart = $november1th.AddDays(- $november1th.DayOfWeek.value__ +1)

        # de herfstvakantie duurt 7 dagen

        for ( $i = 0; $i -lt 7; $i++ ) {
            "$($herfstvakantieStart.AddDays($i).ToString($dateFormat)),herfstvakantie" | Out-File $outFile -Append
        }

        #----------------------------------------------------------------------------------------------------------------------------------------
        # wapenstilstand: 11 november
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Wapenstilstand $schooljaar"

        $wapenstilstand = [DateTime]"$schooljaar-11-11"

        "$($wapenstilstand.ToString($dateFormat)),wapenstilstand" | Out-File $outFile -Append

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Kerstvakantie
        #
        # De kerstvakantie begint op maandag van de week waarin kerstdag valt en duurt 2 weken.
        # Als 25 december (kerstdag) op zaterdag of zondag valt, dan begint de kerstvakantie op maandag na kerstdag.
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Kerstvakantie $schooljaar"

        $kerstDag = [DateTime]"$schooljaar-12-25"

        # Valt kerstdag op een zaterdag (6) of zondag (0), dan begint de kerstvakantie op kerstmaandag

        if ( $kerstDag.DayOfWeek.value__ -eq 6)
        {
            $kerstvakantieStart = $kerstDag.AddDays(2)
        }
        elseif ( $kerstDag.DayOfWeek.value__ -eq 0 )
        {
            $kerstvakantieStart = $kerstDag.AddDays(1)
        }

        # In alle andere gevallen begint de kerstvakantie op de maandag van de week waarin kerstdag valt
        # Valt kerstdag op een maandag, dan begint de kerstvakantie dus op kerstdag

        else
        {
            $kerstvakantieStart = $kerstDag.AddDays(- $kerstDag.DayOfWeek.value__ +1)
        }

        # de kerstvakantie duurt 14 dagen

        for ( $i = 0; $i -lt 14; $i++ ) {
            "$($kerstvakantieStart.AddDays($i).ToString($dateFormat)),kerstvakantie" | Out-File $outFile -Append
        }
        
    #--------------------------------------------------------------------------------------------------------------------------------------------
    # Een nieuw kalenderjaar!
    #--------------------------------------------------------------------------------------------------------------------------------------------

        $schooljaar++

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Pasen
        #
        # source: https://gregfreidline.com/computus-calculating-easter-using-powershell/
        #----------------------------------------------------------------------------------------------------------------------------------------

        $a=$b=$c=$d=$e=$f=$g=$h=$i=$k=$l=$m=$month=$day=0
        [int]$a = $schooljaar % 19
        [double]$b = $schooljaar / 100 
        $b = [math]::Floor($b)
        [int]$c = $schooljaar % 100 
        [double]$d = $b / 4 
        $d = [math]::Floor($d)
        [int]$e = $b % 4
        [int]$f = ($b + 8) / 25
        [double]$g = ($b - $f +1) / 3
        $g = [math]::Floor($g)
        [int]$h = (19*$a + $b - $d - $g + 15) % 30
        [double]$i = $c / 4
        $i = [math]::Floor($i)
        [int]$k = $c % 4
        [int]$l = (32 + 2*$e + 2*$i - $h - $k) % 7
        [double]$m = ($a + 11*$h + 22*$l) / 451
        $m = [math]::Floor($m)
        [double]$month = ($h + $l - 7*$m + 114) / 31
        $month = [math]::Floor($month)
        [int]$day = (($h + $l - 7*$m + 114) % 31)+1
    
        $easterSunday = [DateTime]"$schooljaar-$month-$day"
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Krokusvakantie
        #
        # De krokusvakantie begint op de 7e maandag voor Pasen en duurt 1 week.
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Krokusvakantie $schooljaar"

        # Door 7 keer 7 dagen terug te keren (-7*7) komen we uit op de 7e zondag voor pasen.
        # Daarom tellen we er nog 1 dag bij, om op de gewenste maandag uit te komen
        # In totaal moeten we dus 48 dagen terug in de tijd

        $krokusvakantieStart = $easterSunday.AddDays(-48)

        # de krokusvakantie duurt 7 dagen

        for ( $i = 0; $i -lt 7; $i++ ) {
            "$($krokusvakantieStart.AddDays($i).ToString($dateFormat)),krokusvakantie" | Out-File $outFile -Append
        }

        #----------------------------------------------------------------------------------------------------------------------------------------
        #   De Paasvakantie in Belgie en Vlaanderen vangt in de regel aan op de 1ste maandag van April en duurt 2 weken.
        #
        #   Opgelet:
        #
        #   Als de feestdag Pasen in de maand maart valt, dan begint de Paasvakantie op de maandag na Pasen.
        #   Als de feestdag Pasen na 15 april valt, begint de Paasvakantie op de 2de maandag voor Pasen.
        #   In dat laatste geval wordt de schoolvakantie met één verlofdag verlengd, namelijk met de feestdag Paasmaandag.
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Paasvakantie $schooljaar"

        $april1th  = [DateTime]"$schooljaar-04-01"
        $april15th =  [DateTime]"$schooljaar-04-15"

        # Als de feestdag Pasen in de maand maart valt, dan begint de Paasvakantie op de maandag na Pasen.

        if ( $easterSunday.Month -eq 3 ) { $paasvakantieStart = $easterSunday.AddDays(1) }

        # Als de feestdag Pasen na 15 april valt, begint de Paasvakantie op de 2de maandag voor Pasen.

        elseif ( $easterSunday -gt $april15th ) { $paasvakantieStart = $easterSunday.AddDays(-13) }

        # in alle andere gevallen begint de paasvakantie op de 1ste maandag van April

        else
        {   
            if ( $april1th.DayOfWeek.value__ -le 1) { $paasvakantieStart = $april1th.AddDays(1 - $april1th.DayOfWeek.value__) }
            else { $paasvakantieStart = $april1th.AddDays(8 - $april1th.DayOfWeek.value__) }
        }

        # de paasvakantie duurt 14 dagen

        for ( $i = 0; $i -lt 14; $i++ ) {
            "$($paasvakantieStart.AddDays($i).ToString($dateFormat)),paasvakantie" | Out-File $outFile -Append
        }

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Dag van de Arbeid: 1 mei
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Dag van de Arbeid $schooljaar"

        $dagVanDeArbeid = [DateTime]"$schooljaar-05-01"

        "$($dagVanDeArbeid.ToString($dateFormat)),dag van de arbeid" | Out-File $outFile -Append

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Hemelvaartsdag
        #
        # Hemelvaartsdag valt op de 40e dag van Pasen (dus 39 dagen na eerste paasdag) en 10 dagen voor Pinksteren. 
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Hemelvaart $schooljaar"

        $hemelvaart = $easterSunday.AddDays(39) # is altijd een donderdag

        "$($hemelvaart.ToString($dateFormat)),hemelvaartsdag" | Out-File $outFile -Append

        if ( $toonBrugdagNaHemelvaart ) { "$($hemelvaart.AddDays(1).ToString($dateFormat)),brugdag hemelvaart (behalve voor DKO)" | Out-File $outFile -Append }

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Pinkstermaandag
        #
        # Pinkstermaandag valt 10 dagen na hemelvaartsdag. 
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Pinkstermaandag $schooljaar"

        $pinkstermaandag =  $hemelvaart.AddDays(11)

        "$($pinkstermaandag.ToString($dateFormat)),pinkstermaandag" | Out-File $outFile -Append

        #----------------------------------------------------------------------------------------------------------------------------------------
        # Zomervakantie
        #
        # start: 1 juli - # einde: 31 augustus = 62 vakantiedagen
        #----------------------------------------------------------------------------------------------------------------------------------------

        Write-Debug "Zomervakantie $schooljaar"

        $zomervakantieStart = [DateTime]"$schooljaar-07-01"

        # de zomervakantie duurt 62 dagen

        for ( $i = 0; $i -lt 62; $i++ ) {
            "$($zomervakantieStart.AddDays($i).ToString($dateFormat)),zomervakantie" | Out-File $outFile -Append
        }

        Write-Debug "--"

    }