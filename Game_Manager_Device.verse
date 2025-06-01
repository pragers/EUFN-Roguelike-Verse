using { /Fortnite.com/Game}
using { /Fortnite.com/Playspaces}
using { /Fortnite.com/Devices }
using { /Fortnite.com/Vehicles}
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Colors}
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /Verse.org/Assets}
using { /Verse.org/Native}
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation/Tags}
using { /UnrealEngine.com/Temporary/UI}
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SceneGraph}
using { /Fortnite.com/UI }
using { VerseStuff.PublicFunctions }





StartGameDevice := class(creative_device):
    @editable mutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable mutatorZone2 : mutator_zone_device = mutator_zone_device{}
    @editable CharDev : character_device = character_device{}
    @editable Char2Dev : character_device = character_device{}
    @editable Progress_Manager : Dungeon_Progress_Manager = Dungeon_Progress_Manager{}
    @editable Game_Manager: Game_Manager_Device = Game_Manager_Device{}
    @editable Shop1Test : popup_dialog_device = popup_dialog_device{}
    @editable Camera1 : gameplay_camera_fixed_angle_device = gameplay_camera_fixed_angle_device{}
    @editable itemremove : item_remover_device = item_remover_device{}
    @editable ChoiceInput : input_trigger_device = input_trigger_device{}
    @editable DamageDevs : []damage_volume_device = array{}
    @editable DBNO :down_but_not_out_device  = down_but_not_out_device{}
    @editable RespawnProp : creative_prop = creative_prop{}
    PersistenceManager : Persistence_Manager = Persistence_Manager{}
    @editable UI : UIManager = UIManager{}
    var AgentsIngame : []agent = array{}
    #Subscribes to important events. 
    OnBegin<override>()<suspends>:void=
        AllPlayers:=GetPlayspace().GetPlayers()
        for(Player:AllPlayers):
            if:
                FortChar:= Player.GetFortCharacter[]
            then:
                FortChar.EliminatedEvent().Subscribe(EliminatedPlayerFunc)
        Shop1Test.RespondingButtonEvent.Subscribe(OpenShop1)
        ChoiceInput.PressedEvent.Subscribe(Progress_Manager.ChoicePopUp)
        CharDev.InteractedWithEvent.Subscribe(ButtonFunction)
        Char2Dev.InteractedWithEvent.Subscribe(ButtonFunction2)
        for(DamageDev:DamageDevs):
            DamageDev.AgentEntersEvent.Subscribe(DamagePlayer)
        Game_Manager.Timer.UpdatedEvent.Subscribe(Game_Manager.TimeUpdate)
        Progress_Manager.Timer.UpdatedEvent.Subscribe(UI.UpdateTimerWidget)
        mutatorZone.AgentEntersEvent.Subscribe(EndGame)
        mutatorZone2.AgentEntersEvent.Subscribe(StartGame)
        GetPlayspace().PlayerAddedEvent().Subscribe(Game_Manager.InitializePlayer)
        GetPlayspace().PlayerRemovedEvent().Subscribe(EndGame)
        DBNO.AgentRevivedEvent.Subscribe(StartGame)
        Game_Manager.Init(AllPlayers)
        Game_Manager.Timer.Start()
    ButtonFunction(Agent:agent):void=
        spawn{OpenShopChooser(Agent)}
    OpenStatsUI(Agent:agent)<suspends>:void=
        if:
            Camera := UI.Cameras[1]
        then:
            Camera.AddTo(Agent)
            Sleep(1.3)
            CharDev.PlayEmote()
            OpenStatsMenu(Agent)
    ButtonFunction2(Agent:agent):void=
        spawn{OpenStatsUI(Agent)}
    OpenStatsMenu(Agent:agent):void=
        if:
            CP := Game_Manager.PlayerMap[Agent]
        then:
            UI.StatsUI(Agent,CP)
    OpenShopChooser(Agent:agent)<suspends>:void=
        Camera1.AddTo(Agent)
        Sleep(1.3)
        CharDev.PlayEmote()
        Shop1Test.Show(Agent)
    OpenShop1(Response:tuple(agent,int)):void=
        case(Response(1)):
            0=> UI.Shop1Uiadd(Response(0),0)
            1=> UI.Shop2Uiadd(Response(0),0)
            2=> UI.Shop3Uiadd(Response(0))
            3=> UI.RemoveCamera(Response(0))
            _=>
    #Starts the game on player entering the mutatorzone
    StartGame(Agent:agent):void=
        Print("Player entered zone")
        if: 
            AgentsIngame.Length <=0
        then:
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if:
                    PlayerUi:= GetPlayerUI[Player]
                then:
                    PlayerUi.AddWidget(UI.CreateTimer(Progress_Manager.Timer.GetCurrentTime()))
            Progress_Manager.StartGame(Agent)
            set AgentsIngame += array{Agent}
            Print("{Progress_Manager.AgentsInGame.Length}")
        else:
            if:
                not AgentsIngame.Find[Agent]
            then:
                Progress_Manager.NewWeapons(Agent,false)
                if:
                    not Progress_Manager.AgentsInGame.Find[Agent]
                then:
                    set Progress_Manager.AgentsInGame += array{Agent}
                Print("{Progress_Manager.AgentsInGame.Length}")
                set AgentsIngame += array{Agent}
    EliminatedPlayerFunc(Result:elimination_result):void=
        if:
            Agent:=Result.EliminatedCharacter.GetAgent[]
            not Result.EliminatedCharacter.IsDownButNotOut[]
        then:
            Agent.Respawn(RespawnProp.GetTransform().Translation, IdentityRotation())
            Progress_Manager.GameOverScreen.Play(Agent)
            if:
                CP := Game_Manager.PlayerMap[Agent]
            then:
                set CP.Deaths+=1
            EndGame(Agent)
    EndGame(Agent:agent):void=
        if:
            AgentsIngame.Length <=1
        then:
            Progress_Manager.EndGame(Agent)
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if:
                    PlayerUi:= GetPlayerUI[Player]
                then:
                    PlayerUi.RemoveWidget(UI.canvas1)
        if:
            Array:= AgentsIngame.RemoveFirstElement[Agent]
        then:
            set AgentsIngame = Array
            Progress_Manager.EndAgent(Agent)
            itemremove.Remove(Agent)
    DamagePlayer(Agent:agent):void=
        if:
            FortChar:= Agent.GetFortCharacter[]
        then:
            FortChar.Damage(25.0)




Game_Manager_Device := class(creative_device):
    var PlayerMap : weak_map(player, PlayerStats) = map{}
    PersistenceManager : Persistence_Manager = Persistence_Manager{}
    Timer:custom_timer = custom_timer{Mode:=custom_timer_mode.Seconds}
    # Runs when the device is started in a running game
    TimeUpdate(num:float):void=
        for(Player:GetPlayspace().GetPlayers()):
            if:
                CP := PlayerMap[Player]
            then:
                set CP.TotalTimeSpent+=1.0
                PersistenceManager.UpdatePlayer(Player, CP)
    #Initializes the game
    Init(Players1:[]player):void = 
        for (Player : Players1):
            InitializePlayer(Player)
    
    #initializes the player
    InitializePlayer(Player1:player):void = 
        Print("Initialize player")
        if:
            FC := Player1.GetFortCharacter[]
        then:
            PersistenceManager.InitializePlayer(Player1)
            if:
                PlayerExists := PlayerMap[Player1]
            else:
                PlayerSavedStats := PersistenceManager.GetPlayerData(Player1)
                var SavedUpgrades : [string]Upgrade= PlayerStats{Player:=Player1}.Upgrades
                for(x->Upgrade1:SavedUpgrades):
                    if:
                        Upgrade2 := PlayerSavedStats.Upgrades[x]
                        set SavedUpgrades[x] = Upgrade2
                var SavedUnlocks : [string]Unlock= PlayerStats{Player:=Player1}.Unlocks
                for(x->Unlock1:PlayerSavedStats.Unlocks):
                    if:
                        Unlock2 := PlayerSavedStats.Unlocks[x]
                        set SavedUnlocks[x] = Unlock2
                if(set PlayerMap[Player1] = PlayerStats{
                        Player:= Player1
                        Currency := PlayerSavedStats.Currency
                        Kills := PlayerSavedStats.Kills
                        Deaths := PlayerSavedStats.Deaths
                        Upgrades := SavedUpgrades
                        Unlocks := SavedUnlocks
                        TotalGoldEarned:=PlayerSavedStats.TotalGoldEarned
                        WinsCurrency:=PlayerSavedStats.WinsCurrency
                    }){}
            if(CP := PlayerMap[Player1]):
                CP.Initialize()
                UiText:= UiAmountFormatting(CP.Currency)
                Ui2Text:= UiAmountFormatting(CP.Kills*1.0)
                CP.CurrencyTB.SetText(StringToMessage(UiText))
                CP.Currency2TB.SetText(StringToMessage(Ui2Text))
                CP.CurrencyWinsTB.SetText(StringToMessage("{CP.WinsCurrency}"))
            UpdateUpgrades(Player1)
            if:
                FortChar:= Player1.GetFortCharacter[]
            then:
                FortChar.SetHealth(FortChar.GetMaxHealth())
                FortChar.SetShield(FortChar.GetMaxShield())
    #Adds 'Amount' to the player's current currency and updates player's saved stats
    SubmitCurrency(Reason:string,Player:agent,Amount:float):void=
        Print("Submitting Currency")
        if:
            CP := PlayerMap[Player]
            set CP.Currency += Amount
        then:
            if:
                Amount>0.0
            then:
                set CP.TotalGoldEarned += Amount
            PersistenceManager.UpdatePlayer(Player, CP)
            UpdateCurrencyUI(Player)
            spawn:
                CP.TextPopUp(Reason,Amount)
    SubmitWinCurrency(Player:agent,Amount:int):void=
        if:
            CP := PlayerMap[Player]
            set CP.WinsCurrency += Amount
        then:
            PersistenceManager.UpdatePlayer(Player, CP)
            UpdateCurrencyUI(Player)
    #Increase the player's kill count and updates persistence
    IncreaseKills(Player:agent):void=
        if:
            CP := PlayerMap[Player]
            set CP.Kills += 1
        then:
            PersistenceManager.UpdatePlayer(Player, CP)
            UiText:= UiAmountFormatting(CP.Currency)
            Print("{CP.Kills}")
    
    #Increases the player's kill count and updates persistence
    IncreaseDeaths(Player:agent):void=
        if:
            CP := PlayerMap[Player]
            set CP.Deaths += 1
        then:
            PersistenceManager.UpdatePlayer(Player, CP)
            Print("{CP.Deaths}")
    

    #Tries to buy an upgrade
    TryBuy(Player:agent,UpgradeName:string):logic=
        if:
            CP:= PlayerMap[Player]
            CP.Upgrades[UpgradeName]
            Cost := CP.Upgrades[UpgradeName].Cost*Pow(CP.Upgrades[UpgradeName].CostMulti,CP.Upgrades[UpgradeName].level)
            CP.Currency >= Cost
            CP.Upgrades[UpgradeName].level < CP.Upgrades[UpgradeName].maxLevel
            not CP.Upgrades[UpgradeName].level < 0.0
        then:
            if:
                Newupgrade := Upgrade:
                    level := CP.Upgrades[UpgradeName].level + 1.0
                    maxLevel := CP.Upgrades[UpgradeName].maxLevel
                    multi := CP.Upgrades[UpgradeName].multi * CP.Upgrades[UpgradeName].multiIncrease
                    multiIncrease := CP.Upgrades[UpgradeName].multiIncrease
                    Cost := CP.Upgrades[UpgradeName].Cost
                    CostMulti := CP.Upgrades[UpgradeName].CostMulti
                    Suffix := CP.Upgrades[UpgradeName].Suffix
                    Prefix := CP.Upgrades[UpgradeName].Prefix
                set CP.Upgrades[UpgradeName] = Newupgrade
                set CP.Currency -= Cost
            then:
                PersistenceManager.UpdatePlayer(Player,CP)
                UpdateUpgrades(Player)
                UpdateCurrencyUI(Player)
                return true
        else if:
            CP:= PlayerMap[Player]
            CP.Upgrades[UpgradeName].level < 0.0
            CP.Upgrades[UpgradeName]
            Cost := CP.Upgrades[UpgradeName].Cost
            CP.Currency >= Cost
            CP.Upgrades[UpgradeName].level < CP.Upgrades[UpgradeName].maxLevel
        then:
            if:
                Newupgrade := Upgrade:
                    level := CP.Upgrades[UpgradeName].level + 1.0
                    maxLevel := CP.Upgrades[UpgradeName].maxLevel
                    multi := CP.Upgrades[UpgradeName].multi
                    multiIncrease := CP.Upgrades[UpgradeName].multiIncrease
                    Cost := CP.Upgrades[UpgradeName].Cost
                    CostMulti := CP.Upgrades[UpgradeName].CostMulti
                    Suffix := CP.Upgrades[UpgradeName].Suffix
                    Prefix := CP.Upgrades[UpgradeName].Prefix
                set CP.Upgrades[UpgradeName] = Newupgrade
                set CP.Currency -= Cost
            then:
                PersistenceManager.UpdatePlayer(Player,CP)
                UpdateUpgrades(Player)
                UpdateCurrencyUI(Player)
                return true
        return false
    TryBuyIncrease(Player:agent,UpgradeName:string):logic=
        if:
            CP:= PlayerMap[Player]
            CP.Upgrades[UpgradeName]
            Cost := CP.Upgrades[UpgradeName].Cost*Pow(CP.Upgrades[UpgradeName].CostMulti,CP.Upgrades[UpgradeName].level)
            CP.Currency >= Cost
            CP.Upgrades[UpgradeName].level < CP.Upgrades[UpgradeName].maxLevel
        then:
            if:
                Newupgrade := Upgrade:
                    level := CP.Upgrades[UpgradeName].level + 1.0
                    maxLevel := CP.Upgrades[UpgradeName].maxLevel
                    multi := CP.Upgrades[UpgradeName].multi + CP.Upgrades[UpgradeName].multiIncrease
                    multiIncrease := CP.Upgrades[UpgradeName].multiIncrease
                    Cost := CP.Upgrades[UpgradeName].Cost
                    CostMulti := CP.Upgrades[UpgradeName].CostMulti
                    Suffix := CP.Upgrades[UpgradeName].Suffix
                    Prefix := CP.Upgrades[UpgradeName].Prefix
                set CP.Upgrades[UpgradeName] = Newupgrade
                set CP.Currency -= Cost
            then:
                PersistenceManager.UpdatePlayer(Player,CP)
                UpdateUpgrades(Player)
                UpdateCurrencyUI(Player)
                return true
        return false
    UpdateUpgrades(Agent:agent):void=
        Print("UpdatingUpgrades")
        if:
            CP:= PlayerMap[player[Agent]] 
            Upgrades:= CP.Upgrades
        then:
            if:
                FortChar:= Agent.GetFortCharacter[]
            then:
                if:
                    Health:= Upgrades["Max Health"]
                    HealthMax:=Ceil[Health.multi]
                then:
                    Print("Working")
                    FortChar.SetMaxHealth(HealthMax*1.0)
                if:
                    Shield:= Upgrades["Max Shield"]
                then:
                    if: 
                        Shield.level < 0.0
                    then:
                        FortChar.SetMaxShield(0.0)
                    else if:
                        Shield1 := Ceil[Shield.multi]
                    then:
                        FortChar.SetMaxShield(Shield1*1.0)
    UpdateCurrencyUI(Player:agent):void=
        if:
            CP := PlayerMap[Player]
        then:
            UiText:= UiAmountFormatting(CP.Currency)
            Ui2Text:= UiAmountFormatting(CP.Kills*1.0)
            CP.CurrencyTB.SetText(StringToMessage(UiText))
            CP.Currency2TB.SetText(StringToMessage(Ui2Text))
            CP.CurrencyWinsTB.SetText(StringToMessage("{CP.WinsCurrency}"))
    #Tries to unlock a upgrade
    TryUnlock(Player:agent,UnlockName:string):logic = 
        if:
            CP:= PlayerMap[Player]
            CP.Unlocks[UnlockName]
            CP.Currency >= CP.Unlocks[UnlockName].Cost
            CP.Unlocks[UnlockName].Unlocked = false
        then:
            if:
                NewUnlock := Unlock:
                    Unlocked:= true
                    Cost := CP.Unlocks[UnlockName].Cost
                    Description:= CP.Unlocks[UnlockName].Description
                set CP.Unlocks[UnlockName] = NewUnlock
                set CP.Currency -= CP.Unlocks[UnlockName].Cost
            then:
                PersistenceManager.UpdatePlayer(Player,CP)
                UpdateCurrencyUI(Player)
                return true
        return false
#Converts string to message for ui
StringToMessage<localizes>(String : string) : message = "{String}"
