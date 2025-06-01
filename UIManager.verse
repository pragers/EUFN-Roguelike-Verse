using { /Fortnite.com/Game}
using { /Fortnite.com/Playspaces}
using { /Fortnite.com/Devices }
using { /Fortnite.com/Vehicles}
using { /Fortnite.com/Characters }
using { /Verse.org/Colors}
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /Verse.org/Random }
using { /Verse.org/Assets}
using { /Verse.org/Native}
using { /Verse.org/Simulation/Tags}
using { /UnrealEngine.com/Temporary/UI}
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SceneGraph}
using { /Fortnite.com/UI }
using { VerseStuff.PublicFunctions }
using { VerseStuff.Array }
using { Images }

BuyHandler1:= class():
    Main1:Game_Manager_Device
    UI: UIManager
    Name: string
    Amount: float
    BuySubscription(Message:widget_message):void=
        Worked:= Main1.TryBuy(Message.Player, Name)
        if:
            Worked= true
        then:
            UI.ShopUpdate(Name,Message)
    AddMoney(Message:widget_message):void=
        Main1.SubmitCurrency("Gold",Message.Player,Amount)
    BuyUnlockSub(Message:widget_message):void=
        Worked:= Main1.TryUnlock(Message.Player,Name)
        if:
            Worked= true
        then:
            UI.Shop2Update(Name,Message)
    BuyUnlockSub1(Message:widget_message):void=
        Worked:= Main1.TryUnlock(Message.Player,Name)
        if:
            Worked= true
        then:
            UI.Shop2Update(Name,Message)
GrantHandler := class():
    Choice:Weapon
    GameMan: Game_Manager_Device
    ActivateWeapon(Message:widget_message):void= 
        Agent:= Message.Player
        Choice.ActivateWeapon(Agent, GameMan)
UIHandeler:= class():
    Tab: int
    UIMan:UIManager
    Tabs:[]string
    UpgradeNames:[][]string
    SwitchTab(Message:widget_message):void=
        UIMan.UpdateTab(Message,Tab,Tabs,UpgradeNames)
        
UIManager:= class(creative_device):
    Images1 : [string]texture = map:
        "Currency1" => Gold_Bar 
        "Enemy1Currency" => Guard1
        "Enemy2Currency" => Guard2
        "Boss1Currency" => Guard1
        "Luck" => Luck
        "Health on \nelimination" => Healing
        "Max Health" => Health1
        "Max Shield" => ShieldIcon
        "SMGs" => Hyper_SMG
        "Shotguns" =>PumpShotgun
        "Snipers" =>BoltSniper  
        "Mythics" => HyperSMG
    @editable PopupShop: popup_dialog_device = popup_dialog_device{}
    @editable Main: Game_Manager_Device = Game_Manager_Device{}
    @editable Cameras: []gameplay_camera_fixed_angle_device = array{}
    UpgradesTab1: [][]string = array:
        array{"Currency1"}
        array{"Enemy1Currency","Enemy2Currency"}
        array{"Boss1Currency"}
    UpgradesTab2: [][]string = array:
        array{"Luck","Afk Money"}
        array{"Health on \nelimination","Max Health","Max Shield"}
    NewChoicePopup<public>(Agent:agent, Choices:[]Weapon):void=
        if:
            Player:= player[Agent]
            PlayerUi := GetPlayerUI[Player]
            CP := Main.PlayerMap[Player]
        then:
            CanvasSlot1:=canvas_slot:   
                Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                Offsets := margin{Left := 20.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.0, Y := 0.5}
                SizeToContent := true
                Widget := stack_box:
                    Orientation:= orientation.Vertical
                    Slots:= CreateItemWidgets(Choices)
            MyCanvas:=canvas{}
            MyCanvas.AddWidget(CanvasSlot1)
            set CP.PendingWidget = MyCanvas
            PlayerUi.AddWidget(CP.PendingWidget,player_ui_slot{ZOrder:= 4,InputMode:= ui_input_mode.None})
            Print("Added Widget")
    CreateItemWidgets(Choices:[]Weapon):[]stack_box_slot=
        TextBlock1:= text_block:
            DefaultText:= StringToMessage("Room Completed:")
            DefaultTextColor := White
            DefaultShadowColor := Black
            DefaultShadowOpacity := 1.0
            DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
        StackBoxSlot1:=stack_box_slot{Widget:= TextBlock1}
        var ListArray : []stack_box_slot = array{StackBoxSlot1}
        for(x:Choices):
            var BackgroundImage : color_block = color_block:
                DefaultDesiredSize:= vector2{X:=150.0,Y:=150.0}
                DefaultOpacity := 1.0
            case(x.Rarity1):
                Rarity.Uncommon=> BackgroundImage.SetColor(Green)
                Rarity.Rare => BackgroundImage.SetColor(Blue)
                Rarity.Epic => BackgroundImage.SetColor(Purple)
                Rarity.Legendary => BackgroundImage.SetColor(Orange)
                _ => BackgroundImage.SetColor(Gray)
            var Image_Block : texture_block = texture_block:
                DefaultImage := x.Image
                DefaultDesiredSize:= vector2{X:=150.0,Y:=150.0}
            set ListArray += array:
                stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Left
                    VerticalAlignment:= vertical_alignment.Center
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                    Widget:=Image_Block
        return ListArray
    WeaponChoiceMenuAdd<public>(Agent:agent,Choices:[]Weapon):void=
        if:
            Player:= player[Agent]
            GetPlayerUI[Player]
            PlayerUi := GetPlayerUI[Player]
        then:
            CanvasSlot1:=canvas_slot:   
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.338}
                SizeToContent := true
                Widget := CreateChoiceWidgets(Player, Choices)
            MyCanvas:=canvas{}
            MyCanvas.AddWidget(CanvasSlot1)
            PlayerUi.AddWidget(MyCanvas,player_ui_slot{ZOrder:= 5,InputMode:= ui_input_mode.All})
    CreateChoiceWidgets<public>(Agent:agent,Choices:[]Weapon):widget=
        var ListArray : []stack_box_slot = array{}

        for(Choice :Choices):
            Text1:=text_block:
                DefaultJustification:= text_justification.Center
                DefaultText:= StringToMessage(Choice.Name)
                DefaultTextColor := White
                DefaultShadowColor := Black
                DefaultShadowOpacity := 1.0
                DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}

            var WeaponImage: texture_block = texture_block:
                DefaultImage:= Choice.Image
                DefaultDesiredSize:= vector2{X:=250.0,Y:=250.0}

            var BackgroundImage: texture_block = texture_block{DefaultDesiredSize:= vector2{X:=420.0,Y:=814.0},DefaultImage:=BackGroundChoice}

            case(Choice.Rarity1):
                Rarity.Uncommon=> BackgroundImage.SetTint(Green)
                Rarity.Rare => BackgroundImage.SetTint(Blue)
                Rarity.Epic => BackgroundImage.SetTint(Purple)
                Rarity.Legendary => BackgroundImage.SetTint(Orange)
                _ => BackgroundImage.SetTint(Grey)

            Button:= button_loud{DefaultText := StringToMessage("Choose")}
            Button.OnClick().Subscribe(GrantHandler{Choice:= Choice,GameMan:= Main}.ActivateWeapon)
            Button.OnClick().Subscribe(RemoveUI)

            StackBoxSlot1:=stack_box_slot:
                HorizontalAlignment:= horizontal_alignment.Center
                VerticalAlignment:= vertical_alignment.Center
                Padding:= margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                Widget:= WeaponImage
            StackBoxSlot2:=stack_box_slot:
                HorizontalAlignment:= horizontal_alignment.Fill
                VerticalAlignment:= vertical_alignment.Fill
                Distribution:= option{1.0}
                Padding:= margin{Left := 20.0, Top := 20.0, Right := 20.0, Bottom := 0.0}
                Widget:=Text1
            Stack := stack_box{Orientation:= orientation.Vertical}
            Stack.AddWidget(StackBoxSlot1)
            Stack.AddWidget(StackBoxSlot2)
            if(DpsAmount := Choice.DPS?):
                TextBlock1:=text_block:
                    DefaultJustification:= text_justification.Center
                    DefaultText:= StringToMessage("DPS: {ToTruncatedString(DpsAmount, 1)}")
                    DefaultTextColor := White
                    DefaultShadowColor := Black
                    DefaultShadowOpacity := 1.0
                    DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
                DPS:= stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    VerticalAlignment:= vertical_alignment.Fill
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 20.0, Top := 20.0, Right := 20.0, Bottom := 0.0}
                    Widget:=TextBlock1
                Stack.AddWidget(DPS)
            if(GoldAmount := Choice.GoldAmount?):
                TextBlock1:=text_block:
                    DefaultJustification:= text_justification.Center
                    DefaultText:= StringToMessage(ToTruncatedString(GoldAmount, 0))
                    DefaultTextColor := White
                    DefaultShadowColor := Black
                    DefaultShadowOpacity := 1.0
                    DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
                GoldWidget:=stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    VerticalAlignment:= vertical_alignment.Fill
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 20.0, Top := 20.0, Right := 20.0, Bottom := 0.0}
                    Widget:=TextBlock1
                Stack.AddWidget(GoldWidget)
            Stack.AddWidget(stack_box_slot{Widget:=Button,HorizontalAlignment:= horizontal_alignment.Fill, VerticalAlignment:= vertical_alignment.Bottom, Distribution:= option{1.0}, Padding:= margin{Left := 20.0, Top := 10.0, Right := 20.0, Bottom := 10.0}})
            Overlay2:=overlay:
                Slots:= array:
                    overlay_slot:
                        HorizontalAlignment:= horizontal_alignment.Center
                        VerticalAlignment:= vertical_alignment.Center
                        Widget:= color_block:
                            DefaultDesiredSize:= vector2{X:=420.0,Y:=620.0}
                            DefaultOpacity := 0.0
                            DefaultColor := Black
                    overlay_slot:
                        HorizontalAlignment:= horizontal_alignment.Center
                        VerticalAlignment:= vertical_alignment.Center
                        Padding:= margin{Left := 40.0, Top := 40.0, Right := 40.0, Bottom := 40.0}
                        Widget:= Stack
            OverlaySlot1:=overlay_slot:
                HorizontalAlignment:= horizontal_alignment.Center
                VerticalAlignment:= vertical_alignment.Top
                Widget:= BackgroundImage
            OverlaySlot2:=overlay_slot:
                Padding:= margin{Left := 0.0, Top := 20.0, Right := 0.0, Bottom := 0.0}
                HorizontalAlignment:= horizontal_alignment.Center
                VerticalAlignment:= vertical_alignment.Top
                Widget:= Overlay2
            MyOverlay: overlay = overlay{}
            MyOverlay.AddWidget(OverlaySlot1)
            MyOverlay.AddWidget(OverlaySlot2)
            set ListArray += array:
                stack_box_slot:
                    Padding:= margin{Left := 20.0, Top := 0.0, Right := 20.0, Bottom := 0.0}
                    VerticalAlignment:= vertical_alignment.Center
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Distribution:= option{1.0}
                    Widget:= MyOverlay
        return stack_box{Orientation:= orientation.Horizontal,Slots:= ListArray}

    #Start of Shop1
    Shop2Uiadd<public>(Agent:agent,Tab:int):void=
        Tabs:= array{"Luck","Health"}
        if:
            Player:= player[Agent]
            GetPlayerUI[Player]
            CP:= Main.PlayerMap[Player]
            PlayerUi := GetPlayerUI[Player]
            Upgrades:= UpgradesTab2[Tab]
        then:
            NewWidget:= ShopUi(Player,CP.Upgrades,Upgrades,option{Tabs},option{Tab},UpgradesTab2)
            PlayerUi.AddWidget(NewWidget,player_ui_slot{ZOrder:= 5,InputMode:= ui_input_mode.All})
    Shop1Uiadd<public>(Agent:agent,Tab:int):void=
        Tabs:= array{"General","Guards","Bosses"}
        if:
            Player:= player[Agent]
            GetPlayerUI[Player]
            CP:= Main.PlayerMap[Player]
            PlayerUi := GetPlayerUI[Player]
            Upgrades:= UpgradesTab1[Tab]
        then:
            NewWidget:= ShopUi(Player,CP.Upgrades,Upgrades,option{Tabs},option{Tab},UpgradesTab1)
            PlayerUi.AddWidget(NewWidget,player_ui_slot{ZOrder:= 5,InputMode:= ui_input_mode.All})


    ShopUi(Player:player, Upgrade1:[string]Upgrade,Upgrades:[]string,Tabs:?[]string,CurrentTab:?int,UpgradeNames:[][]string):canvas=
        var UpgradesMap: [string]Upgrade = map{}
        for(Upgrade2:Upgrades):
            if:
                Index1:= Upgrade1[Upgrade2]
                set UpgradesMap[Upgrade2] = Index1
        if(CP:= Main.PlayerMap[Player]):
            set CP.OpenTab = CreateUpgradeWidget(Player,UpgradesMap,Tabs,CurrentTab,UpgradeNames)
            ColorBlock1:=texture_block{DefaultDesiredSize:= vector2{X:=1220.0,Y:=720.0},DefaultImage:=BackGroundUI}
            OverlaySlot1:= overlay_slot{Widget:= ColorBlock1}
            OverlaySlot2:=overlay_slot:
                HorizontalAlignment:= horizontal_alignment.Fill
                VerticalAlignment:= vertical_alignment.Fill
                Padding:= margin{Left := 40.0, Top := 40.0, Right := 40.0, Bottom := 40.0}
                Widget:= CP.OpenTab
            Overlay1:= overlay{}
            Overlay1.AddWidget(OverlaySlot1)
            Overlay1.AddWidget(OverlaySlot2)
            MyCanvas:canvas = canvas{}
            CanvasSlot1:=canvas_slot:   
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                SizeToContent := true
                Widget := Overlay1
            MyCanvas.AddWidget(CanvasSlot1)
            return MyCanvas
        return canvas{}
    UpdateTab(Message:widget_message,Tab:int,Tabs:[]string,UpgradeNames:[][]string):void=
        if:
            Upgrades:= UpgradeNames[Tab]
            CP:= Main.PlayerMap[Message.Player]
        then:
            if:
                Widget:= Message.Source.GetRootWidget[]
                Canvas1:= canvas[Widget]
                Widget1:=CP.OpenTab.GetParentWidget[]
            then:
                Canvas1.RemoveWidget(Widget1)
                var UpgradesMap: [string]Upgrade = map{}
                for(Upgrade2:Upgrades):
                    if:
                        Index1:= CP.Upgrades[Upgrade2]
                        set UpgradesMap[Upgrade2] = Index1
                set CP.OpenTab = CreateUpgradeWidget(Message.Player,UpgradesMap,option{Tabs},option{Tab},UpgradeNames)
                ColorBlock:= texture_block{DefaultDesiredSize:= vector2{X:=1220.0,Y:=720.0},DefaultImage:= BackGroundUI}
                Overlayslot1:=overlay_slot{Widget:= ColorBlock}
                Overlayslot2:= overlay_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    VerticalAlignment:= vertical_alignment.Fill
                    Padding:= margin{Left := 40.0, Top := 40.0, Right := 40.0, Bottom := 40.0}
                    Widget:= CP.OpenTab
                Overlay1 := overlay{}
                Overlay1.AddWidget(Overlayslot1)
                Overlay1.AddWidget(Overlayslot2)
                CanvasSlot:= canvas_slot:   
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Overlay1
                Canvas1.AddWidget(CanvasSlot)
    
    CreateUpgradeWidget(Player:player, Upgrade1:[string]Upgrade,Tabs:?[]string,CurrentTab:?int,UpgradeNames:[][]string):stack_box=
        Closebutton:= button_loud:
            DefaultText := StringToMessage("<")
        Closebutton.OnClick().Subscribe(RemoveShopUI)
        Closebutton.OnClick().Subscribe(ShowPopup)
        MyStackBox:= stack_box:
            Orientation:= orientation.Horizontal
            Slots:= array:
                stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Left
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                    Widget:= Closebutton
        for(X->Tab:Tabs?):
            var Mybutton:text_button_base=button_quiet:
                DefaultText := StringToMessage(Tab)
            if:
                Y:= CurrentTab?
                X=Y
            then:
                set Mybutton= button_regular:
                    DefaultText := StringToMessage(Tab)
            if:
                Tab1:= Tabs?
            then:
                Mybutton.OnClick().Subscribe(UIHandeler{Tab:=X,UIMan:=Self,Tabs:=Tab1,UpgradeNames:=UpgradeNames}.SwitchTab)
            MyStackBoxSlot:= stack_box_slot:
                HorizontalAlignment:= horizontal_alignment.Fill
                Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                Widget:= Mybutton
                Distribution:= option{1.0}
            MyStackBox.AddWidget(MyStackBoxSlot)
        var ListArray: []stack_box_slot = array{
            stack_box_slot:
                HorizontalAlignment:= horizontal_alignment.Fill
                Padding:= margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 10.0}
                Widget:= MyStackBox
        }
        for(x->UpgradeInfo : Upgrade1):
            
            Text1:=text_block:
                DefaultText:= StringToMessage(x)
                DefaultTextColor := White
                DefaultShadowColor := Black
                DefaultShadowOpacity := 1.0
                DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
            Text2:=text_block:
                DefaultText := StringToMessage("{UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi)}{UpgradeInfo.Suffix} -> {UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi*UpgradeInfo.multiIncrease)}{UpgradeInfo.Suffix}")
                DefaultTextColor := White
                DefaultShadowColor := Black
                DefaultShadowOpacity := 1.0
                DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
                DefaultJustification := text_justification.Center
            Text3:= text_block:
                DefaultTextColor := White
                DefaultShadowColor := Black
                DefaultShadowOpacity := 1.0
                DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
                DefaultJustification := text_justification.Center
            Text4:=text_block:
                DefaultTextColor := White
                DefaultShadowColor := Black
                DefaultShadowOpacity := 1.0
                DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}
                DefaultText:= StringToMessage("Cost: ${UiAmountFormatting(UpgradeInfo.Cost*Pow(UpgradeInfo.CostMulti,UpgradeInfo.level))}")
            Button:= button_loud:
                DefaultText := StringToMessage("Buy")
            if:
                UpgradeInfo.level >= 0.0
            then:
                Text3.SetText(StringToMessage("level:{ToTruncatedString(UpgradeInfo.level,0)}/{ToTruncatedString(UpgradeInfo.maxLevel,0)}"))
            else:
                Text3.SetText(StringToMessage("Locked"))
                Button.SetText(StringToMessage("Unlock"))
            if:
                UpgradeInfo.level <0.0
            then:
                Text2.SetText(StringToMessage("{UpgradeInfo.Prefix}0{UpgradeInfo.Suffix}-> {UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi)}{UpgradeInfo.Suffix}"))
                Button.SetText(StringToMessage("${UiAmountFormatting(UpgradeInfo.Cost)}"))
            if:
                UpgradeInfo.level >= UpgradeInfo.maxLevel
            then:
                Button.SetText(StringToMessage("Max Level"))
                Text2.SetText(StringToMessage("{UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi)}{UpgradeInfo.Suffix} -> Max"))
            if:
                Main.PlayerMap[Player]
                set Main.PlayerMap[Player].Text2Map[x]=Text2
                set Main.PlayerMap[Player].Text3Map[x]=Text3
                set Main.PlayerMap[Player].Text4Map[x]=Text4
                set Main.PlayerMap[Player].ButtonMap[x]=Button
                Text2CP:= Main.PlayerMap[Player].Text2Map[x]
                Text3CP:= Main.PlayerMap[Player].Text3Map[x]
                Text4CP:= Main.PlayerMap[Player].Text4Map[x]
                ButtonCP:= Main.PlayerMap[Player].ButtonMap[x]
            then:
                ButtonCP.OnClick().Subscribe(BuyHandler1{UI:= Self,Main1:= Main,Name:=x,Amount:=0.0}.BuySubscription)
                TextStack := stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Top
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                    Widget:= Text1
                StackBox2:= stack_box:
                    Orientation := orientation.Vertical
                    Slots:= array:
                        stack_box_slot:
                            HorizontalAlignment:= horizontal_alignment.Fill
                            Distribution:= option{1.0}
                            Padding:= margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 5.0}
                            Widget:= Text3CP
                        stack_box_slot:
                            HorizontalAlignment:= horizontal_alignment.Fill
                            Distribution:= option{1.0}
                            Padding:= margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                            Widget:= Text2CP
                Text2Stack := stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                    Widget:= StackBox2
                Text4Stack := stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                    Widget:= Text4CP
                BoxStack := stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Distribution:= option{1.0}
                    Padding:= margin{Left := 10.0, Top := 10.0, Right := 0.0, Bottom := 10.0}
                    Widget:= ButtonCP
                Widget1:= stack_box:
                    Orientation := orientation.Horizontal
                if:
                    Image:= Images1[x]
                then:
                    TextureStack:= stack_box_slot:
                        HorizontalAlignment:= horizontal_alignment.Fill
                        Distribution:= option{0.5}
                        Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                        Widget:= overlay:
                            Slots:=array:
                                overlay_slot:
                                    HorizontalAlignment:= horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget:=texture_block:
                                        DefaultImage:= Image
                                        DefaultDesiredSize := vector2{X:=75.0,Y:=75.0}
                    Widget1.AddWidget(TextureStack)
                Widget1.AddWidget(TextStack)
                Widget1.AddWidget(Text2Stack)
                Widget1.AddWidget(Text4Stack)
                Widget1.AddWidget(BoxStack)
                set ListArray += array:
                    stack_box_slot:
                        Padding:= margin{Left := 5.0, Top := 0.0, Right := 5.0, Bottom := 0.0}
                        HorizontalAlignment:= horizontal_alignment.Fill
                        Widget:=Widget1
        MyWidget: stack_box = stack_box:
            Orientation := orientation.Vertical
            Slots:= ListArray
        
        return MyWidget
    
    ShopUpdate<public>(Name:string,Message:widget_message):void=
        if:
            Text2CP:= Main.PlayerMap[Message.Player].Text2Map[Name]
            Text3CP:= Main.PlayerMap[Message.Player].Text3Map[Name]
            Text4CP:= Main.PlayerMap[Message.Player].Text4Map[Name]
            ButtonCP:= Main.PlayerMap[Message.Player].ButtonMap[Name]
            Upgrades:=Main.PlayerMap[Message.Player].Upgrades
            UpgradeInfo:= Upgrades[Name]
        then:
            Text2CP.SetText(StringToMessage("{UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi)}{UpgradeInfo.Suffix} -> {UpgradeInfo.Prefix}{UiAmountFormatting(UpgradeInfo.multi*UpgradeInfo.multiIncrease)}{UpgradeInfo.Suffix}"))
            Text3CP.SetText(StringToMessage("level:{ToTruncatedString(UpgradeInfo.level,0)}/{ToTruncatedString(UpgradeInfo.maxLevel,0)}"))
            Text4CP.SetText(StringToMessage("Cost: ${UiAmountFormatting(UpgradeInfo.Cost*Pow(UpgradeInfo.CostMulti,UpgradeInfo.level))}"))
    #End of SHOP1

    Shop3Uiadd<public>(Agent:agent):void=
        Upgrades:= array{}
        if:
            Player:= player[Agent]
            GetPlayerUI[Player]
            CP:= Main.PlayerMap[Player]
            PlayerUi := GetPlayerUI[Player]
        then:
            NewWidget:= ShopUnlockUi(Player,CP.Unlocks,Upgrades)
            PlayerUi.AddWidget(NewWidget,player_ui_slot{ZOrder:= 5,InputMode:= ui_input_mode.All})

    
    ShopUnlockUi(Player:player, Upgrade1:[string]Unlock,Upgrades:[]string):canvas=
        var UpgradesMap: [string]Unlock = map{}
        for(Upgrade2:Upgrades):
            if:
                Index1:= Upgrade1[Upgrade2]
                set UpgradesMap[Upgrade2] = Index1
        ColoWidget1:= overlay_slot:
            Widget:=texture_block:
                DefaultDesiredSize:= vector2{X:=1220.0,Y:=720.0}
                DefaultImage:= BackGroundUI
        ListWidget:= CreateUnlockWidget(Player,Upgrade1)
        ListWidgetSlot:= overlay_slot:
            HorizontalAlignment:= horizontal_alignment.Fill
            VerticalAlignment:= vertical_alignment.Fill
            Padding:= margin{Left := 40.0, Top := 40.0, Right := 40.0, Bottom := 40.0}
            Widget:= ListWidget
        Overlay1:= overlay{}
        Overlay1.AddWidget(ColoWidget1)
        Overlay1.AddWidget(ListWidgetSlot)
        CanvasSlot:= canvas_slot:   
            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
            Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
            Alignment := vector2{X := 0.5, Y := 0.5}
            SizeToContent := true
            Widget := Overlay1
        MyCanvas:canvas = canvas{}
        MyCanvas.AddWidget(CanvasSlot)
        return MyCanvas
    
    CreateUnlockWidget(Player:player, Upgrade1:[string]Unlock):widget=
        Closebutton:= button_loud{DefaultText := StringToMessage("<")}
        Closebutton.OnClick().Subscribe(RemoveShopUI)
        Closebutton.OnClick().Subscribe(ShowPopup)
        var ListArray: []stack_box_slot = array:
            stack_box_slot{HorizontalAlignment:= horizontal_alignment.Left,Padding:= margin{Left := 10.0, Top := 0.0, Right := 10.0, Bottom := 10.0},Widget:= Closebutton}
        for(x->UpgradeInfo : Upgrade1):
            Text1:=text_block{DefaultText:= StringToMessage(x),DefaultTextColor := White,DefaultShadowColor := Black,DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}}
            Text2:=text_block{DefaultText := StringToMessage(""),DefaultTextColor := White,DefaultShadowColor := Black,DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}}
            Text3:= text_block{DefaultTextColor := White,DefaultShadowColor := Black, DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}},DefaultJustification:= text_justification.Center}
            if(desc:= UpgradeInfo.Description?):
                Text3.SetText(StringToMessage(desc))
            Button:= button_loud{DefaultText := StringToMessage("${UiAmountFormatting(UpgradeInfo.Cost)}")}
            if(UpgradeInfo.Unlocked = true){Button.SetText(StringToMessage("Unlocked"))}
            if:
                Main.PlayerMap[Player]
                set Main.PlayerMap[Player].Shop2Text2Map[x]=Text2
                set Main.PlayerMap[Player].Shop2ButtonMap[x]=Button
                Text2CP:= Main.PlayerMap[Player].Shop2Text2Map[x]
                ButtonCP:= Main.PlayerMap[Player].Shop2ButtonMap[x]
            then:
                ButtonCP.OnClick().Subscribe(BuyHandler1{UI:= Self,Main1:= Main,Name:=x,Amount:=0.0}.BuyUnlockSub)
                TextStack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text1}
                Text2Stack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{0.5},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text2CP}
                Text3Stack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Left,Distribution:= option{2.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text3}
                ButtonStack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= ButtonCP}
                Widget1:=stack_box{Orientation := orientation.Horizontal}
                if(Image:= Images1[x]):
                    ImageBlock:= texture_block{DefaultImage:= Image,DefaultDesiredSize := vector2{X:=75.0,Y:=75.0}}
                    TextureStack:= stack_box_slot:
                        HorizontalAlignment:= horizontal_alignment.Fill
                        Distribution:= option{0.5}
                        Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                        Widget:= overlay:
                            Slots:=array:
                                overlay_slot:
                                    HorizontalAlignment:= horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget:=ImageBlock
                    Widget1.AddWidget(TextureStack)
                Widget1.AddWidget(TextStack)
                Widget1.AddWidget(Text2Stack)
                Widget1.AddWidget(Text3Stack)
                Widget1.AddWidget(ButtonStack)
                MyStackBoxSlot:= stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Widget:= Widget1
                set ListArray += array:
                    MyStackBoxSlot
        MyWidget: widget = stack_box:
            Orientation := orientation.Vertical
            Slots:= ListArray
        return MyWidget
    CreateUnlockWinWidget(Player:player, Upgrade1:[string]Unlock):widget=
        Closebutton:= button_loud{DefaultText := StringToMessage("<")}
        Closebutton.OnClick().Subscribe(RemoveShopUI)
        Closebutton.OnClick().Subscribe(ShowPopup)
        var ListArray: []stack_box_slot = array:
            stack_box_slot{HorizontalAlignment:= horizontal_alignment.Left,Padding:= margin{Left := 10.0, Top := 0.0, Right := 10.0, Bottom := 10.0},Widget:= Closebutton}
        for(x->UpgradeInfo : Upgrade1):
            Text1:=text_block{DefaultText:= StringToMessage(x),DefaultTextColor := White,DefaultShadowColor := Black,DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}}
            Text2:=text_block{DefaultText := StringToMessage(""),DefaultTextColor := White,DefaultShadowColor := Black,DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}}}
            Text3:= text_block{DefaultTextColor := White,DefaultShadowColor := Black, DefaultShadowOpacity := 1.0,DefaultShadowOffset := option{vector2{X:=3.0,Y:=3.0}},DefaultJustification:= text_justification.Center}
            if(desc:= UpgradeInfo.Description?):
                Text3.SetText(StringToMessage(desc))
            Button:= button_loud{DefaultText := StringToMessage("${UiAmountFormatting(UpgradeInfo.Cost)}")}
            if(UpgradeInfo.Unlocked = true){Button.SetText(StringToMessage("Unlocked"))}
            if:
                Main.PlayerMap[Player]
                set Main.PlayerMap[Player].Shop2Text2Map[x]=Text2
                set Main.PlayerMap[Player].Shop2ButtonMap[x]=Button
                Text2CP:= Main.PlayerMap[Player].Shop2Text2Map[x]
                ButtonCP:= Main.PlayerMap[Player].Shop2ButtonMap[x]
            then:
                ButtonCP.OnClick().Subscribe(BuyHandler1{UI:= Self,Main1:= Main,Name:=x,Amount:=0.0}.BuyUnlockSub1)
                TextStack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text1}
                Text2Stack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{0.5},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text2CP}
                Text3Stack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Left,Distribution:= option{2.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= Text3}
                ButtonStack:=stack_box_slot{HorizontalAlignment:= horizontal_alignment.Fill,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0},Widget:= ButtonCP}
                Widget1:=stack_box{Orientation := orientation.Horizontal}
                if(Image:= Images1[x]):
                    ImageBlock:= texture_block{DefaultImage:= Image,DefaultDesiredSize := vector2{X:=75.0,Y:=75.0}}
                    TextureStack:= stack_box_slot:
                        HorizontalAlignment:= horizontal_alignment.Fill
                        Distribution:= option{0.5}
                        Padding:= margin{Left := 0.0, Top := 10.0, Right := 10.0, Bottom := 10.0}
                        Widget:= overlay:
                            Slots:=array:
                                overlay_slot:
                                    HorizontalAlignment:= horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget:=ImageBlock
                    Widget1.AddWidget(TextureStack)
                Widget1.AddWidget(TextStack)
                Widget1.AddWidget(Text2Stack)
                Widget1.AddWidget(Text3Stack)
                Widget1.AddWidget(ButtonStack)
                MyStackBoxSlot:= stack_box_slot:
                    HorizontalAlignment:= horizontal_alignment.Fill
                    Widget:= Widget1
                set ListArray += array:
                    MyStackBoxSlot
        MyWidget: widget = stack_box:
            Orientation := orientation.Vertical
            Slots:= ListArray
        return MyWidget
    Shop2Update<public>(Name:string,Message:widget_message):void=
        if:
            Text2CP:= Main.PlayerMap[Message.Player].Shop2Text2Map[Name]
            Button2CP:= Main.PlayerMap[Message.Player].Shop2ButtonMap[Name]
            Upgrades:=Main.PlayerMap[Message.Player].Unlocks
            UpgradeInfo:= Upgrades[Name]
        then:
            Text2CP.SetText(StringToMessage(""))
            if(UpgradeInfo.Unlocked = true)then Button2CP.SetText(StringToMessage("Unlocked")) else Button2CP.SetText(StringToMessage("${UiAmountFormatting(UpgradeInfo.Cost)}"))

    ShowPopup<public>(Message:widget_message):void=
        PopupShop.Show(Message.Player)
    RemoveShopUI<public>(Message:widget_message):void=
        RemoveUI(Message)
        if(Cp:=Main.PlayerMap[Message.Player]) then Cp.Initialize()

    RemoveUI<public>(Message:widget_message):void=
        if:
            Widget:=Message.Source.GetRootWidget[]
            PlayerUI:= GetPlayerUI[Message.Player]
        then:
            PlayerUI.RemoveWidget(Widget)
    
    TimerWidget:text_block= text_block{DefaultTextColor:= White}
    canvas1<public> :canvas= canvas{}

    CreateTimer<public>(Time:float):canvas=
        TimerWidget.SetText(StringToMessage("{TimeFormatting(Time)}"))
        canvas1.AddWidget(canvas_slot:
            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.1}
            Maximum := vector2{X := 0.5, Y := 0.1}}
            Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
            Alignment := vector2{X := 0.5, Y := 0.5}
            SizeToContent := true
            Widget:= TimerWidget
        )
        return canvas1

    UpdateTimerWidget<public>(Time:float):void= 
        TimerWidget.SetText(StringToMessage("{TimeFormatting(Time)}"))
    RemoveCamera1<public>(Message:widget_message):void=
        RemoveCamera(Message.Player)
    RemoveCamera<public>(Agent:agent):void=
        for(Camera:Cameras):
            Camera.RemoveFrom(Agent)
    StatsUI(Agent:agent,Stats:PlayerStats):void=
        var fastestTime : float = 0.0;
        if:
            PlayerUI:= GetPlayerUI[player[Agent]]
        then:
            
            PlayerName:= PlayerNameToMessage(Agent)
            NameTextBlock:= text_block{DefaultText:= PlayerName,DefaultTextColor:= White}
            TimePlayedTextBlock:= text_block{DefaultText:= StringToMessage("Time Played: {TimeFormatting(Stats.TotalTimeSpent)}"),DefaultTextColor:= White}
            KDTextBlock:= text_block{DefaultText:= StringToMessage("K/D: Undefined"),DefaultTextColor:= White}
            KillsTextBlock:= text_block{DefaultText:= StringToMessage("Kills: {Stats.Kills}"),DefaultTextColor:= White}
            DeathsTextBlock:= text_block{DefaultText:= StringToMessage("Deaths: {Stats.Deaths}"),DefaultTextColor:= White}
            TotalGoldEarnedTextBlock:= text_block{DefaultText:= StringToMessage("Total Gold Earned: {UiAmountFormatting(Stats.TotalGoldEarned)}"),DefaultTextColor:= White}
            WinsTextBlock:= text_block{DefaultText:= StringToMessage("Wins: {Stats.Wins}"),DefaultTextColor:= White}
            FastestTimeTextBlock:= text_block{DefaultText:= StringToMessage("Fastest Time: TBD"),DefaultTextColor:= White}
            TotalUpgradesTextBlock:= text_block{DefaultText:= StringToMessage("Total Upgrades: 0"),DefaultTextColor:= White}
            CloseButton:= button_loud{DefaultText:= StringToMessage("x")}
            BackGroundWidget:= texture_block{DefaultImage:= BackGroundUI,DefaultDesiredSize:= vector2{X:=590.0,Y:=570.0}}
            CloseButton.OnClick().Subscribe(RemoveUI)
            CloseButton.OnClick().Subscribe(RemoveCamera1)
            if:
                not Stats.Deaths = 0
            then:
                KDTextBlock.SetText(StringToMessage("K/D: {ToTruncatedString((Stats.Kills*1.0)/(1.0*Stats.Deaths),1)}"))
            if:
                FastestTime := Stats.Times.MinBy[VerseStuff.Array.Sort.CompareFloats]
                set fastestTime = FastestTime
            then:
                FastestTimeTextBlock.SetText(StringToMessage("Fastest Time: {TimeFormatting(fastestTime)}"))
            var TotalUpgrades: int = 0
            for(Upgrade1:Stats.Upgrades):
                if:
                    set TotalUpgrades += Round[Upgrade1.level]
            if(TotalUpgrades>0) {TotalUpgradesTextBlock.SetText(StringToMessage("Total Upgrades bought: {TotalUpgrades}"))}
            TopWidget:= stack_box:
                Orientation:= orientation.Horizontal
                Slots:= array:
                    stack_box_slot{Widget:= NameTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Center,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= CloseButton,HorizontalAlignment:= horizontal_alignment.Right,VerticalAlignment:= vertical_alignment.Fill,Distribution:= option{1.0},Padding:= margin{Left :=0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}}
            ListWidget := stack_box:
                Orientation := orientation.Vertical
                Slots:= array:
                    stack_box_slot{Widget:= TopWidget,HorizontalAlignment:= horizontal_alignment.Fill,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{2.0},Padding:= margin{Left :=0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= TimePlayedTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left :=0.0, Top := 20.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= FastestTimeTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= WinsTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left :=0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= KDTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left :=0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= KillsTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= DeathsTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= TotalGoldEarnedTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}},
                    stack_box_slot{Widget:= TotalUpgradesTextBlock,HorizontalAlignment:= horizontal_alignment.Left,VerticalAlignment:= vertical_alignment.Top,Distribution:= option{1.0},Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 10.0}}
            OverlaySlot1:= overlay_slot:
                HorizontalAlignment:= horizontal_alignment.Center
                VerticalAlignment:= vertical_alignment.Center
                Widget:= BackGroundWidget
            OverlaySlot2:= overlay_slot:
                HorizontalAlignment:= horizontal_alignment.Fill
                VerticalAlignment:= vertical_alignment.Top
                Padding:= margin{Left := 40.0, Top := 40.0, Right := 40.0, Bottom := 40.0}
                Widget:= ListWidget
            Overlay1:= overlay{}
            Overlay1.AddWidget(OverlaySlot1)
            Overlay1.AddWidget(OverlaySlot2)
            canvasSlot1:= canvas_slot:   
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5}
                SizeToContent := true
                Widget := Overlay1
            canvas2:= canvas{}
            canvas2.AddWidget(canvasSlot1)
            PlayerUI.AddWidget(canvas2,player_ui_slot{ZOrder:= 6,InputMode:= ui_input_mode.All})
PlayerNameToMessage<localizes>(Agent:agent):message = "{Agent}'s Stats"
