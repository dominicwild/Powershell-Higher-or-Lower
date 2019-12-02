
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
    $guess = switch($guess){
        "higher" { 1 }
        "high" { 1 }
        "h" { 1 }
        "lower" { 0 }
        "low" { 0 }
        "l" { 0 }
    }
}

function borderLine(){
    Write-Host "------------------------------"
}

#$name = Read-Host -Prompt "What is your name?"
#Write-Host "Your name is" $name

$s = import-csv cards.csv
$deck = [Deck]::new($s)
$card = $deck.draw()
$points = 0

borderLine

while($deck.cards.Count -gt 0){   

  Write-Host "The " -NoNewline 
  $card.display() 
  Write-Host " has been drawn"
  Write-Host "There are" $deck.cards.Count "cards remaining"
  Write-Host "Higher or lower? (h/l)" 
  $guess = Read-Host

  $nextCard = $deck.draw()
  Write-Host "The next card drawn is " -NoNewline
  $nextCard.display()
  Write-Host

  if($guess -and $card.getValue() -le $nextCard.getValue() ){

    $points++
    Write-Host "Correct, the next card was higher. You now have" $points "points"
    
  } elseif ($card.getValue() -gt $nextCard.getValue()) { 

    $points++
    Write-Host "Correct, the next card was lower. You now have" $points "points"
    
  } else {
    Write-Host "You guessed incorrectly and ended the game with" $points "points"
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
