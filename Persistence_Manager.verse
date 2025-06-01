
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }



#Custom player class for saving data
Custom_player := class<final><persistable>:
    Currency : float = 0.0
    Kills : int = 0
    Deaths:int = 0
    TotalGoldEarned:float=0.0
    WinsCurrency :int = 0
    Upgrades : [string]Upgrade = map{
        "Currency1" => Upgrade{level:=0.0,maxLevel:=20.0,multi:=1.0,multiIncrease:=1.2,Cost:=100.0,CostMulti:=1.6,Prefix:="$",Suffix:=""}
        "Enemy1Currency" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=10.0,multiIncrease:=1.05,Cost:=100.0,CostMulti:=1.25,Prefix:="$",Suffix:=""}
        "Enemy2Currency" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=25.0,multiIncrease:=1.1,Cost:=250.0,CostMulti:=1.4,Prefix:="$",Suffix:=""}
        "Boss1Currency" => Upgrade{level:= 0.0, maxLevel:= 10.0,multi:=100.0,multiIncrease:=1.5,Cost:=1000.0,CostMulti:=2.0,Prefix:="$",Suffix:=""}
        "Luck" => Upgrade{level:=0.0,maxLevel:=50.0,multi:=1.0,multiIncrease:=1.1,Cost:=10.0,CostMulti:=1.33,Prefix:="",Suffix:="x"}
        "Health on \nelimination" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=10.0,multiIncrease:= 1.0965,Cost:=100.0,CostMulti:=1.35,Prefix:="",Suffix:="HP"}
        "Max Health" => Upgrade{level:=0.0,maxLevel:=100.0,multi:=100.0,multiIncrease:=1.01,Cost:=100.0,CostMulti:=1.2,Prefix:="",Suffix:="HP"}
        "Max Shield" => Upgrade{level:=-1.0,maxLevel:=25.0,multi:=5.0,multiIncrease:=1.15,Cost:=150.0,CostMulti:=1.4,Prefix:="",Suffix:=""}
        "Afk Money" => Upgrade{level:=-1.0, maxLevel:= 100.0,multi:=1.0,multiIncrease:=1.1,Cost:=1000.0,CostMulti:=1.33,Prefix:="$",Suffix:="/s"}
    }
    Unlocks : [string]Unlock = map{
        "SMGs" => Unlock{Cost:= 300.0,Unlocked:= false, Description:= false}
        "Shotguns" => Unlock{Cost:= 2000.0,Unlocked:= false, Description:= false}
        "Snipers" => Unlock{Cost:= 100000.0,Unlocked:= false, Description:= false}
        "Mythics" => Unlock{Cost:= 1000000.0,Unlocked:= false, Description:=  option{"Small chance to get \na mythic weapon"}}
    }
var player_map : weak_map(player, Custom_player) = map{}
#Returns a Custom_player with the same values as OldTable
CreateCustomPlayer<constructor>(OldTable:Custom_player)<transacts> := Custom_player :
    Currency := OldTable.Currency
    Kills := OldTable.Kills
    Deaths := OldTable.Deaths
    Upgrades := OldTable.Upgrades
    Unlocks := OldTable.Unlocks
    TotalGoldEarned:= OldTable.TotalGoldEarned
    WinsCurrency:= OldTable.WinsCurrency

#persistance manager manages save data for all players
Persistence_Manager := class():
    #Creates a new Custom_player if not found in the player_map
    InitializePlayer(Player:player) : void = 
        if:
            Player.IsActive[]
            not player_map[Player]
            set player_map[Player] = Custom_player{}
    #gets the data of the player
    GetPlayerData(Agent:agent) : Custom_player = 
        var NewPlayer : Custom_player = Custom_player{}
        if:
            Player:= player[Agent]
            PlayerTable:= player_map[Player]
            set NewPlayer = PlayerTable

        return NewPlayer
    #updates the players stat by amount
    UpdatePlayer(Agent:agent,PlayerStatsTable:PlayerStats): void = 
        if:
            Player:= player[Agent]
            Player.IsActive[]
            PlayerTable := player_map[Player]
        then:
            if:
                set player_map[Player] = Custom_player{
                    CreateCustomPlayer<constructor>(PlayerTable)
                    Currency:= PlayerStatsTable.Currency
                    Kills:= PlayerStatsTable.Kills
                    Deaths:= PlayerStatsTable.Deaths
                    Upgrades:= PlayerStatsTable.Upgrades
                    Unlocks:= PlayerStatsTable.Unlocks
                    TotalGoldEarned:= PlayerStatsTable.TotalGoldEarned
                    WinsCurrency := PlayerStatsTable.WinsCurrency
                }
