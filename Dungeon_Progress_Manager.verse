using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { Images }

Rarity<public> := enum:
    Common
    Uncommon
    Rare
    Epic
    Legendary
    Mythic
WeaponType<public>:= enum:
    Gun
    Misc
    Gold
    Health
    Shield
Powerup_message:=struct:
    Player:player
    Duration:?int
Weapon<public>:= class():
    @editable Name<public>:string
    @editable DPS<public>:?float
    @editable Rarity1<public> : Rarity
    @editable Image: texture = Ranger_Pistol
    @editable GoldAmount<public>:?float
    @editable Granter<public>:?item_granter_device
    @editable Weight<public>:float
    @editable Type<public>: WeaponType
    ActivateWeapon(Agent:agent,GameMan:Game_Manager_Device):void=
        case(Type):
            WeaponType.Gun=> GrantItem(Agent)
            WeaponType.Gold => GrantGold(Agent, GameMan)
            WeaponType.Misc=>
            WeaponType.Health=>GrantHealth(Agent,GameMan)
            WeaponType.Shield=>GrantShield(Agent,GameMan)
    GrantItem(Agent:agent):void=
        if:
            GranterDev:= Granter?
        then:
            GranterDev.GrantItem(Agent)
    GrantGold(Agent:agent,Game_Man:Game_Manager_Device):void=
        if:
            GoldAmount1 := GoldAmount?
        then:
            Game_Man.SubmitCurrency("Gold",Agent,GoldAmount1)
    GrantHealth(Agent:agent,Game_Man:Game_Manager_Device):void=
        if:
            GoldAmount1 := GoldAmount?
            Player:=player[Agent]
            FortChar:= Player.GetFortCharacter[]
        then:
            FortChar.Heal(GoldAmount1)
    GrantShield(Agent:agent,Game_Man:Game_Manager_Device):void=
        if:
            GoldAmount1 := GoldAmount?
            Player:=player[Agent]
            FortChar:= Player.GetFortCharacter[]
        then:
            FortChar.SetShield(FortChar.GetShield()+GoldAmount1)

Stage:= class():
    @editable Spawners : []guard_spawner_device = array{}
    @editable Barrier : []objective_device = array{}


Dungeon_Progress_Manager := class(creative_device):
    var AgentsDamager : [agent][]player = map{}
    var Agents: []agent = array{}
    var CurrentStage:int = 0
    Timer :custom_timer= custom_timer{Mode:=custom_timer_mode.Seconds}
    @editable Game_Manager: Game_Manager_Device= Game_Manager_Device{}
    @editable RespawnProp : creative_prop = creative_prop{}
    @editable Spawners : []Stage = array{}
    @editable Enemy1Spawners : []guard_spawner_device = array{}
    @editable Enemy2Spawners : []guard_spawner_device = array{}
    @editable Enemy3Spawners : []guard_spawner_device = array{}
    @editable Enemy10Spawners : []guard_spawner_device = array{}
    @editable ParkourFinish : []mutator_zone_device = array{}
    @editable UI : UIManager = UIManager{}
    @editable Inputdev : input_trigger_device = input_trigger_device{}
    @editable TotalAssistDev : analytics_device = analytics_device{}
    @editable AgentKillDev : analytics_device = analytics_device{}
    @editable AgentAssistDev : analytics_device = analytics_device{}
    @editable Agent1KillDev : analytics_device = analytics_device{}
    @editable Agent2AssistDev : analytics_device = analytics_device{}
    @editable Agent2KillDev : analytics_device = analytics_device{}
    @editable Agent3AssistDev : analytics_device = analytics_device{}
    @editable Agent3KillDev : analytics_device = analytics_device{}
    @editable Agent10AssistDev : analytics_device = analytics_device{}
    @editable Agent10KillDev : analytics_device = analytics_device{}
    @editable StageClearedDev : analytics_device = analytics_device{}
    @editable windev : analytics_device = analytics_device{}
    @editable RoundSFX : audio_player_device = audio_player_device{}
    @editable KillSFX : audio_player_device = audio_player_device{}
    @editable GameOverScreen : cinematic_sequence_device = cinematic_sequence_device{}
    @editable VictoryScreen : cinematic_sequence_device = cinematic_sequence_device{}

    @editable Pistol: []Weapon = array:
        Weapon{Name:="Ranger Pistol",DPS:= option{158.4},Rarity1:= Rarity.Common,Image:= Ranger_Pistol,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Hand Cannon",DPS:= option{100.0},Rarity1:= Rarity.Uncommon,Image:= Hand_Cannon,GoldAmount:=false,Granter:=false,Weight:=50.0,Type:=WeaponType.Gun}
        Weapon{Name:="Hand Cannon",DPS:= option{67.2},Rarity1:= Rarity.Legendary,Image:= HandCannon,GoldAmount:=false,Granter:=false,Weight:=50.0,Type:=WeaponType.Gun}
        Weapon{Name:="Hand Cannon",DPS:= option{64.0},Rarity1:= Rarity.Epic,Image:= HandCannon,GoldAmount:=false,Granter:=false,Weight:=100.0,Type:=WeaponType.Gun}
        Weapon{Name:="Suppressed Pistol",DPS:= option{168.75},Rarity1:= Rarity.Uncommon,Image:= Suppressed_Pistol,GoldAmount:=false,Granter:=false,Weight:=700.0,Type:=WeaponType.Gun}
        Weapon{Name:="Revolver",DPS:= option{48.6},Rarity1:= Rarity.Common,Image:= Revolver,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Monarch Pistol",DPS:= option{103.2},Rarity1:= Rarity.Rare,Image:= MonarchPistol,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
    @editable MythicPistol:[]Weapon = array:
        Weapon{Name:="Conductor Hand Cannon",DPS:= option{72.1},Rarity1:= Rarity.Mythic,Image:= HandCannon,GoldAmount:=false,Granter:=false,Weight:=1.0,Type:=WeaponType.Gun}
    @editable Smgs: []Weapon = array:
        Weapon{Name:="Burst SMG",DPS:= option{180.0},Rarity1:= Rarity.Common,Image:= Burst_SMG,GoldAmount:=false,Granter:=false,Weight:=900.0,Type:=WeaponType.Gun}
        Weapon{Name:="Combat SMG",DPS:= option{216.0},Rarity1:= Rarity.Common,Image:= Combat_SMG,GoldAmount:=false,Granter:=false,Weight:=900.0,Type:=WeaponType.Gun}
        Weapon{Name:="Hyper SMG",DPS:= option{346.58},Rarity1:= Rarity.Uncommon,Image:= Hyper_SMG,GoldAmount:=false,Granter:=false,Weight:=650.0,Type:=WeaponType.Gun}
        Weapon{Name:="Rapid Fire SMG",DPS:= option{195.0},Rarity1:= Rarity.Common,Image:= RapidFireSMG,GoldAmount:=false,Granter:=false,Weight:=900.0,Type:=WeaponType.Gun}
        Weapon{Name:="Rapid Fire SMG",DPS:= option{225.0},Rarity1:= Rarity.Rare,Image:= RapidFireSMG,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
        Weapon{Name:="Stinger SMG",DPS:= option{180.0},Rarity1:= Rarity.Common,Image:= StingeSMG,GoldAmount:=false,Granter:=false,Weight:=900.0,Type:=WeaponType.Gun}
        Weapon{Name:="Stinger SMG",DPS:= option{216.0},Rarity1:= Rarity.Epic,Image:= StingeSMG,GoldAmount:=false,Granter:=false,Weight:=100.0,Type:=WeaponType.Gun}
        Weapon{Name:="Machine SMG",DPS:= option{202.5},Rarity1:= Rarity.Uncommon,Image:= Combat_SMG,GoldAmount:=false,Granter:=false,Weight:=700.0,Type:=WeaponType.Gun}
    @editable MythicSMG: []Weapon = array:
        Weapon{Name:="Hyper SMG",DPS:= option{180.0},Rarity1:= Rarity.Mythic,Image:= HyperSMG,GoldAmount:=false,Granter:=false,Weight:=1.0,Type:=WeaponType.Gun}
    @editable Misc: []Weapon = array:
        Weapon{Name:="Gold",DPS:= false,Rarity1:= Rarity.Legendary,Image:= Gold_Bar,GoldAmount:=option{500.0},Granter:=false,Weight:=50.0,Type:=WeaponType.Gold}
        Weapon{Name:="Gold",DPS:= false,Rarity1:= Rarity.Legendary,Image:= Gold_Bar,GoldAmount:=option{100.0},Granter:=false,Weight:=200.0,Type:=WeaponType.Gold}
        Weapon{Name:="Health",DPS:= false,Rarity1:= Rarity.Rare,Image:= Healing,GoldAmount:=option{50.0},Granter:=false,Weight:=100.0,Type:=WeaponType.Health}
    @editable Shield: []Weapon = array:
        Weapon{Name:="Shield",DPS:= false,Rarity1:= Rarity.Rare,Image:= ShieldIcon,GoldAmount:=option{10.0},Granter:=false,Weight:=200.0,Type:=WeaponType.Shield}
    @editable Shotgun : []Weapon = array:
        Weapon{Name:="Hammer pump shotgun",DPS:= option{82.72},Rarity1:= Rarity.Rare,Image:= HammerPumpShotgun,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
        Weapon{Name :="Tactical Shotgun",DPS:= option{100.5},Rarity1:= Rarity.Common,Image:= TacShotgun,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Frenzy auto shotgun",DPS:= option{187.0},Rarity1:= Rarity.Rare,Image:= FrenzyAutoShotgun,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
        Weapon{Name:="Combat shotgun",DPS:= option{102.0},Rarity1:= Rarity.Common,Image:= CombatShotgun,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Thunder shotgun",DPS:= option{69.92},Rarity1:= Rarity.Common,Image:= ThunderShotgun,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Thunder shotgun",DPS:= option{80.56},Rarity1:= Rarity.Rare,Image:= ThunderShotgun,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
        Weapon{Name:="Thunder shotgun",DPS:= option{89.68},Rarity1:= Rarity.Legendary,Image:= ThunderShotgun,GoldAmount:=false,Granter:=false,Weight:=30.0,Type:=WeaponType.Gun}
        Weapon{Name:="Pump shotgun",DPS:= option{63.0},Rarity1:= Rarity.Common,Image:= PumpShotgun,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Pump shotgun",DPS:= option{83.3},Rarity1:= Rarity.Epic,Image:= PumpShotgun,GoldAmount:=false,Granter:=false,Weight:=100.0,Type:=WeaponType.Gun}
    @editable MythicShotgun: []Weapon = array:
        Weapon{Name:="Drum shotgun",DPS:= option{195.0},Rarity1:= Rarity.Mythic,Image:= DrumShotgun,GoldAmount:=false,Granter:=false,Weight:=1.0,Type:=WeaponType.Gun}
    @editable Sniper : []Weapon = array:
        Weapon{Name:="Heavy Sniper Rifle",DPS:= option{76.8},Rarity1:= Rarity.Epic,Image:= HeavySniper,GoldAmount:=false,Granter:=false,Weight:=100.0,Type:=WeaponType.Gun}
        Weapon{Name:="Heavy Sniper Rifle",DPS:= option{84.48},Rarity1:= Rarity.Legendary,Image:= HeavySniper,GoldAmount:=false,Granter:=false,Weight:=50.0,Type:=WeaponType.Gun}
        Weapon{Name:="Reaper Sniper Rifle",DPS:= option{55.65},Rarity1:= Rarity.Uncommon,Image:= ReaperSniper,GoldAmount:=false,Granter:=false,Weight:=700.0,Type:=WeaponType.Gun}
        Weapon{Name:="Reaper Sniper Rifle",DPS:= option{61.48},Rarity1:= Rarity.Epic,Image:= ReaperSniper,GoldAmount:=false,Granter:=false,Weight:=100.0,Type:=WeaponType.Gun}
        Weapon{Name:="Reaper Sniper Rifle",DPS:= option{64.13},Rarity1:= Rarity.Legendary,Image:= ReaperSniper,GoldAmount:=false,Granter:=false,Weight:=50.0,Type:=WeaponType.Gun}
        Weapon{Name:="Bolt-Action Sniper",DPS:= option{31.5},Rarity1:= Rarity.Common,Image:= BoltSniper,GoldAmount:=false,Granter:=false,Weight:=1000.0,Type:=WeaponType.Gun}
        Weapon{Name:="Lever Action Rifle",DPS:= option{83.75},Rarity1:= Rarity.Uncommon,Image:= BoltSniper,GoldAmount:=false,Granter:=false,Weight:=700.0,Type:=WeaponType.Gun}
        Weapon{Name:="Lever Action Rifle",DPS:= option{87.5},Rarity1:= Rarity.Rare,Image:= BoltSniper,GoldAmount:=false,Granter:=false,Weight:=300.0,Type:=WeaponType.Gun}
    @editable MythicSniper: []Weapon = array:
        Weapon{Name:="Heavy Sniper Rifle",DPS:= option{88.32},Rarity1:= Rarity.Mythic,Image:= HeavySniper,GoldAmount:=false,Granter:=false,Weight:=1.0,Type:=WeaponType.Gun}
    var AgentsInGame: []agent = array{}
    # Runs when the device is started in a running game
    StartGame(Agent:agent):void=
        Timer.Start()
        if:
            Spawn:= Spawners[0]
        then:
            Print("Starting game")
            for(spawner:Spawn.Spawners):
                spawner.Enable()
            for(Door:Spawn.Barrier):
                Door.Hide()
            set CurrentStage += 1
        for(x->spawner: Spawners):
            for(y->spawns:spawner.Spawners):
                spawns.SpawnedEvent.Subscribe(GuardSpawned)
        for(Spawner: Enemy1Spawners):
            Spawner.EliminatedEvent.Subscribe(Enemy1Killed)
        for(Spawner: Enemy2Spawners):
            Spawner.EliminatedEvent.Subscribe(Enemy2Killed)
        for(Spawner: Enemy3Spawners):
            Spawner.EliminatedEvent.Subscribe(Enemy3Killed)
        for(Spawner: Enemy10Spawners):
            Spawner.EliminatedEvent.Subscribe(Enemy10Killed)
        for(Zone:ParkourFinish):
            Zone.AgentEntersEvent.Subscribe(ParkourFini)
            Zone.AgentEntersEvent.Subscribe(ParkourFini)
        set AgentsInGame += array{Agent}
        NewWeapons(Agent,false)


    EndGame(Agent:agent):void=
        for(spawner : Spawners):
            for(spawn1:spawner.Spawners):
                spawn1.Disable()
                spawn1.Reset()
            for(Door:spawner.Barrier):
                Door.Show()
        for(dev: ParkourFinish):
            dev.Enable()
        set CurrentStage = 0
        set Agents = array{}
        AllPlayers:= GetPlayspace().GetPlayers()
        for(Player:AllPlayers):
            EndAgent(Player)
        Timer.Reset()
        set AgentsInGame = array{}
    EndAgent(Agent:agent):void=
        if:
            CP:= Game_Manager.PlayerMap[player[Agent]]
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            PlayerUI.RemoveWidget(CP.PendingWidget)
            set CP.PendingWeapons = array{}
            Inputdev.Unregister(Agent)
        if:
            NewArray:= AgentsInGame.RemoveFirstElement[Agent]
        then:
            set AgentsInGame = NewArray

    GuardSpawned(Agent:agent):void =
        set Agents += array{Agent}
        if:
            set AgentsDamager[Agent] = array{}
        if:
            FortChar:= Agent.GetFortCharacter[]
        then:
            FortChar.DamagedEvent().Subscribe(GuardDamaged)
    GuardDamaged(Result:damage_result):void=
        if:
            Agent:= fort_character[Result.Target].GetAgent[]
            Source:=Result.Instigator?.GetInstigatorAgent[]
            Player:=player[Source]
            not AgentsDamager[Agent].Find[Player]
            set AgentsDamager[Agent] += array{Player}
    Enemy1Killed(Result:device_ai_interaction_result):void=
        GuardKilled(Result, 1)
    Enemy2Killed(Result:device_ai_interaction_result):void=
        GuardKilled(Result, 2)
    Enemy3Killed(Result:device_ai_interaction_result):void=
        GuardKilled(Result, 3)
    Enemy10Killed(Result:device_ai_interaction_result):void=
        GuardKilled(Result, 10)
    ChoicePopUp(Agent:agent):void=
        if:
            CP:= Game_Manager.PlayerMap[player[Agent]]
            CP.PendingWeapons.Length > 0
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            UI.WeaponChoiceMenuAdd(Agent,CP.PendingWeapons)
            PlayerUI.RemoveWidget(CP.PendingWidget)
            set CP.PendingWeapons = array{}
            Inputdev.Unregister(Agent)

    NewWeapons(Agent:agent,IncludeMisc:logic):void=
        var Misc1 : []Weapon = Misc
        if:
            CP:= Game_Manager.PlayerMap[player[Agent]]
            CP.PendingWeapons.Length > 0
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            PlayerUI.RemoveWidget(CP.PendingWidget)
            set CP.PendingWeapons = array{}
            Inputdev.Unregister(Agent)
            if:
                CP.Upgrades["Max Shield"].level >0.0
            then:
                set Misc1 += Shield
        var Lootpool : []Weapon = array{}
        set Lootpool+=Pistol
        if:
            IncludeMisc = true
        then:
            set Lootpool+=Misc1
        if:
            CP:= Game_Manager.PlayerMap[Agent]
            
        then:
            if(CP.Unlocks["Mythics"].Unlocked){set Lootpool += MythicPistol}
            if:
                CP.Unlocks["SMGs"].Unlocked = true
            then:
                set Lootpool += Smgs
                if(CP.Unlocks["Mythics"].Unlocked){set Lootpool += MythicSMG}
            if:
                CP.Unlocks["Shotguns"].Unlocked = true
            then:
                set Lootpool += Shotgun
                if(CP.Unlocks["Mythics"].Unlocked){set Lootpool += MythicShotgun}
            if:
                CP.Unlocks["Snipers"].Unlocked = true
            then:
                set Lootpool += Sniper
                if(CP.Unlocks["Mythics"].Unlocked){set Lootpool += MythicSniper}
        if:
            CP:= Game_Manager.PlayerMap[Agent]
        then:
            RandomLootPool:= Shuffle(Lootpool)
            Weapons := GetRandomItems(RandomLootPool, 3, CP.GetLuck())
            set CP.PendingWeapons = Weapons
            if:
                IncludeMisc = false
            then:   
                ChoicePopUp(Agent)
            else:
                Inputdev.Register(Agent)
                UI.NewChoicePopup(Agent,CP.PendingWeapons)
            
    
    GuardKilled(Result:device_ai_interaction_result,EnemyType:int) :void =
        if:
            Agent := Result.Target?
            NewArray := Agents.RemoveFirstElement[Agent]
        then:
            set Agents = NewArray
            Print("{Agents.Length}")
            if:
                Agents.Length < 1
            then:
                NextStage()
        if:
            Agent:= Result.Source?
        then:
            KillSFX.Play(Agent)
            AgentKillDev.Submit(Agent)
            Game_Manager.IncreaseKills(Agent)
            if:
                CP := Game_Manager.PlayerMap[Agent]
                Amount := 1.0 * CP.Upgrades["Currency1"].multi
            then:
                if:
                    FortChar:= Agent.GetFortCharacter[]
                    HealAmount:= CP.Upgrades["Health on \nelimination"].multi
                then:
                    FortChar.Heal(HealAmount)
                if:
                    EnemyType = 1
                    NewAmount := CP.Upgrades["Enemy1Currency"].multi * Amount
                then:
                    Agent1KillDev.Submit(Agent)
                    Game_Manager.SubmitCurrency("Elimination",Agent,NewAmount)
                else if:
                    EnemyType = 2
                    NewAmount := CP.Upgrades["Enemy2Currency"].multi *Amount
                then:
                    Agent2KillDev.Submit(Agent)
                    Game_Manager.SubmitCurrency("Elimination",Agent,NewAmount)
                else if:
                    EnemyType = 3
                    NewAmount := CP.Upgrades["Enemy3Currency"].multi *Amount
                then: 
                    Agent3KillDev.Submit(Agent)
                    Game_Manager.SubmitCurrency("Elimination",Agent,NewAmount)
                else if:
                    EnemyType= 10
                    NewAmount := CP.Upgrades["Boss1Currency"].multi *Amount
                then: 
                    Agent10KillDev.Submit(Agent)
                    Game_Manager.SubmitCurrency("Elimination",Agent,NewAmount)
                else:
                    Game_Manager.SubmitCurrency("Elimination",Agent,Amount)
            if:
                AgentKilled:= Result.Target?
                DamagingPlayers:[]player= AgentsDamager[AgentKilled]
            then:
                for (Player: DamagingPlayers):
                    if: 
                        not Player = player[Agent]
                    then:
                        GiveAssist(Player,EnemyType)


    GiveAssist(Player:player,EnemyType:int):void=
        TotalAssistDev.Submit(Player)
        KillSFX.Play(Player)
        if:
            CP := Game_Manager.PlayerMap[Player]
            Amount := 0.5 * CP.Upgrades["Currency1"].multi
        then:
            if:
                EnemyType = 1
                NewAmount := CP.Upgrades["Enemy1Currency"].multi * Amount
            then:
                AgentAssistDev.Submit(Player)
                Game_Manager.SubmitCurrency("Assist",Player,NewAmount)
            else if:
                EnemyType = 2
                NewAmount := CP.Upgrades["Enemy2Currency"].multi *Amount
            then:
                Agent2AssistDev.Submit(Player)
                Game_Manager.SubmitCurrency("Assist",Player,NewAmount)
            else if:
                EnemyType = 3
                NewAmount := CP.Upgrades["Enemy3Currency"].multi *Amount
            then: 
                Agent3AssistDev.Submit(Player)
                Game_Manager.SubmitCurrency("Assist",Player,NewAmount)
            else if:
                EnemyType= 10
                NewAmount := CP.Upgrades["Boss1Currency"].multi *Amount
            then: 
                Agent10AssistDev.Submit(Player)
                Game_Manager.SubmitCurrency("Elimination",Player,NewAmount)
            else:
                AgentAssistDev.Submit(Player)
                Game_Manager.SubmitCurrency("Assist",Player,Amount)

    NextStage():void=
        if:
            CurrentStage = Spawners.Length
        then:
            Print("Ended Game")
            VictoryFunc()
            return
        RoundSFX.Play()
        if:
            CurrentSpawners := Spawners[CurrentStage]
        then:
            AllPlayers:= GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if:
                    AgentsInGame.Find[Player]
                then:
                    StageClearedDev.Submit(Player)
                    NewWeapons(Player,true)
            for(CurrentBarrier:CurrentSpawners.Barrier):
                CurrentBarrier.Hide()
            for(Spawner:CurrentSpawners.Spawners):
                Spawner.Enable()
            set CurrentStage += 1
    GetRandomItems(Choices:[]Weapon,Number:int,Luck1:float):[]Weapon = 
        var RemainingItems:[]Weapon = Choices
        var ChosenItems:[]Weapon = array{}
        if:
            Choices.Length = Number
        then:
            return Choices
        for(x:=0..Number-1):
            var TotalWeight:float = 0.0
            for(X:RemainingItems):
                set TotalWeight += X.Weight
            var AdjustedEntries : []Weapon = array{}
            for(X: RemainingItems):
                AdjWeight:= X.Weight / Pow(TotalWeight/(TotalWeight-X.Weight),Luck1-1.0)
                set AdjustedEntries += array: 
                    Weapon:
                        Name:= X.Name
                        DPS:= X.DPS
                        Rarity1:= X.Rarity1
                        Image:=X.Image
                        GoldAmount:=X.GoldAmount
                        Granter:=X.Granter
                        Weight:=AdjWeight
                        Type:= X.Type
                
            var TotalAdjWeight:float = 0.0
            for(X:AdjustedEntries):
                set TotalAdjWeight += X.Weight
            var Rand :float= GetRandomFloat(0.0,TotalAdjWeight)
            var CumulativeWeight:float = 0.0
            var Found : logic = false
            for(Y->X:AdjustedEntries):
                set CumulativeWeight+= X.Weight
                if:
                    Found = false
                    Rand<CumulativeWeight
                then:
                    set Found = true
                    set ChosenItems += array{X}
                    if:
                        NewArray:= RemainingItems.RemoveElement[Y]
                    then:
                        set RemainingItems = NewArray
        return ChosenItems
    ParkourFini(Player:agent):void =
        NextStage()
        Game_Manager.SubmitCurrency("Parkour Completed",Player, 100.0)
    VictoryFunc():void=
        Print("VictoryFunc Activated")
        Time := Timer.GetCurrentTime()
        AllPlayers:= GetPlayspace().GetPlayers()
        Print("{AllPlayers.Length}")
        VictoryScreen.Play()
        for(x->Agent:AgentsInGame):
            Print("{x}")
            spawn{AgentVictoryFunc(Agent,Time)}
    AgentVictoryFunc(Agent:agent,Time:float)<suspends>:void=
        windev.Submit(Agent)
        if:
            CP:= Game_Manager.PlayerMap[player[Agent]]
        then:
            set CP.Wins +=1
            set CP.Times += array{Time}
        Game_Manager.SubmitWinCurrency(Agent, 1)
        Sleep(3.0)
        Print("Teleporting")
        Agent.Respawn(RespawnProp.GetTransform().Translation,RespawnProp.GetTransform().Rotation)
        EndGame(Agent)
    TestButtonFunc(Agent:agent):void=
        VictoryFunc()
