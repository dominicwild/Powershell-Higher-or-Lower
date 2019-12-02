
class Card {
    [string] $suit
    [string] $value

    hidden Init([string]$suit, [string]$value){
        $this.suit = $suit
        $this.value = $value #Could make into enum
    }

    Card([string]$suit, [string]$value){
        $this.Init($suit,$value)
    }

    [int] getValue(){
        $result = switch($this.value){
            "ACE" {1}
            "2" {2}
            "3" {3}
            "4" {4}
            "5" {5}
            "6" {6}
            "7" {7}
            "8" {8}
            "9" {9}
            "10" {10}
            "KING" {11}
            "QUEEN" {12}
            "JACK" {13}
        }
        #Write-Host $result
        return $result
    }

    [string] toString(){
        return $this.value + " of " + $this.suit + "'s"
    }

    display(){
        Write-Host $this.toString() -ForegroundColor Yellow -NoNewline
    }

}

class Deck{

    [Array] $cards

    Deck([Array]$cards){
        $this.cards = @()
        foreach($card in $cards){
            $this.cards += ([Card]::new($card.suit,$card.value))
        }
        $this.shuffle()
    }
 
    shuffle(){
        $this.cards = $this.cards | Sort-Object {Get-Random} 
    }

    [Card]draw(){
        $card, $this.cards = $this.cards
        return $card
    }

}

function processGuess([string] $guess){
    [OutputType([int])]
    $guess = switch($guess){
        "higher" { 1 }
        "high" { 1 }
        "h" { 1 }
        "lower" { 0 }
        "low" { 0 }
        "l" { 0 }
    }
    $guess
}

function borderLine(){
    Write-Host "------------------------------"
}

$validColours = @("black","darkblue","darkgreen","darkcyan","darkred","darkmagenta","darkyellow","gray","darkgray","blue","green","cyan","red","magenta","yellow","white")

function Write-Color([string] $text) {

    #Syntax of <red> text </red>
    #$textArray = [regex]::split("Some red <red> text </red> That also has some <yellow> text for us all </yellow>","(<.+?>.+?<\/.+?>)")
    $textArray = [regex]::split($text,"(<.+?>.+?<\/.+?>)")

    foreach($text in $textArray) {
        $text = $text.Trim()
        if($text -And $text[0] -eq "<") {
            $color = [regex]::Split($text,"<(.+?)>")
            $text = $color[2]
            $color = $color[1]
            
            if($validColours -contains $color.ToLower() ){
                Write-Host $text -ForegroundColor $color -NoNewline
            } else {
                Write-Host $text -NoNewline
            }
        } else {
            Write-Host $text -NoNewline
        }
    }
    Write-Host
}

#$name = Read-Host -Prompt "What is your name?"
#Write-Host "Your name is" $name

$s = import-csv cards.csv
$deck = [Deck]::new($s)
$card = $deck.draw()
$points = 0

borderLine

while($deck.cards.Count -gt 0){   

  Write-Color("The <yellow> " + $card.toString() + " </yellow> has been drawn")
  Write-Color("There are <cyan> " + $deck.cards.Count + " </cyan> cards remaining")
  Write-Host "Higher or lower? (h/l)" 
  $guess = processGuess(Read-Host)

  $nextCard = $deck.draw()
  Write-Color("The next card drawn is <yellow> " + $nextCard.toString() + " </yellow> ")

  if($guess -and $card.getValue() -le $nextCard.getValue() ){

    $points++
    Write-Color("<green>Correct, the next card was higher.</green><magenta> You now have " + $points + " points </magenta>")
    
  } elseif ($guess -and $card.getValue() -gt $nextCard.getValue()) { 

    $points++
    Write-Color("<green>Correct, the next card was lower.</green> <magenta> You now have " +  $points + " points<magenta>")
    
  } else {
    Write-Color("<red>You guessed incorrectly and ended the game with</red><magenta> " + $points + " points</magenta>")
    break
  }

  if($deck.cards.Count -eq 0){
    Write-Host "Deck is empty, deck is being reshuffled."
    $deck = [Deck]::new($s)
    $deck.cards.Remove($nextCard)
  }

  $card = $nextCard

  borderLine

}
