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
using { Images }
#Upgrades affect the player's stats
Upgrade := struct<persistable>:
    level : float
    maxLevel : float
    multi : float
    multiIncrease:float
    Cost : float
    CostMulti : float
    Prefix : string
    Suffix : string
#Unlocks are upgrades which have only 1 level, they are saves seperately
Unlock := struct<persistable>:
    Unlocked:logic
    Cost:float
    Description: ?string

#Custom Class for saving player stats while in game, synced with the custom player class in the persistence manager.
PlayerStats := class<unique>():
    Player:player
    var Currency : float= 0.0
    var WinsCurrency:int = 0
    var Kills : int = 0
    var Deaths : int = 0
    var Wins : int = 0
    var TotalGoldEarned : float = 0.0
    var TotalTimeSpent : float = 0.0
    var Times : []float = array{}
    var PendingWeapons : []Weapon = array{}
    var PendingWidget : canvas = canvas{}
    var OpenTab: stack_box = stack_box{Orientation:= orientation.Horizontal}
    var Upgrades : [string]Upgrade = map:
        "Currency1" => Upgrade{level:=0.0,maxLevel:=20.0,multi:=1.0,multiIncrease:=1.2,Cost:=100.0,CostMulti:=1.6,Prefix:="$",Suffix:=""}
        "Enemy1Currency" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=10.0,multiIncrease:=1.05,Cost:=100.0,CostMulti:=1.25,Prefix:="$",Suffix:=""}
        "Enemy2Currency" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=25.0,multiIncrease:=1.1,Cost:=250.0,CostMulti:=1.4,Prefix:="$",Suffix:=""}
        "Boss1Currency" => Upgrade{level:= 0.0, maxLevel:= 10.0,multi:=100.0,multiIncrease:=1.5,Cost:=1000.0,CostMulti:=2.0,Prefix:="$",Suffix:=""}
        "Luck" => Upgrade{level:=0.0,maxLevel:=50.0,multi:=1.0,multiIncrease:=1.1,Cost:=10.0,CostMulti:=1.33,Prefix:="",Suffix:="x"}
        "Health on \nelimination" => Upgrade{level:=0.0,maxLevel:=25.0,multi:=10.0,multiIncrease:= 1.0965,Cost:=100.0,CostMulti:=1.35,Prefix:="",Suffix:="HP"}
        "Max Health" => Upgrade{level:=0.0,maxLevel:=100.0,multi:=100.0,multiIncrease:=1.01,Cost:=100.0,CostMulti:=1.2,Prefix:="",Suffix:="HP"}
        "Max Shield" => Upgrade{level:=-1.0,maxLevel:=25.0,multi:=5.0,multiIncrease:=1.15,Cost:=150.0,CostMulti:=1.4,Prefix:="",Suffix:=""}
        "Afk Money" => Upgrade{level:=-1.0, maxLevel:= 100.0,multi:=1.0,multiIncrease:=1.1,Cost:=1000.0,CostMulti:=1.33,Prefix:="$",Suffix:="/s"}
    var Unlocks : [string]Unlock = map:
        "SMGs" => Unlock{Cost:= 150.0,Unlocked:= false, Description:= false}
        "Shotguns" => Unlock{Cost:= 1500.0,Unlocked:= false, Description:= false}
        "Snipers" => Unlock{Cost:= 10000.0,Unlocked:= false, Description:= false}
    var CurrencyTB : text_block = text_block:
        DefaultTextColor := Black
    var Currency2TB : text_block = text_block:
        DefaultTextColor := Black
    var CurrencyWinsTB :text_block= text_block:
        DefaultTextColor := Black
    Initialize() : void=
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(CreateUI(),player_ui_slot{ZOrder:=1,InputMode:=ui_input_mode.None})
    var Text2Map: [string]text_block= map{}
    var Text3Map: [string]text_block= map{}
    var Text4Map: [string]text_block= map{}
    var ButtonMap : [string]button_loud = map{}
    var Shop2Text2Map: [string]text_block= map{}
    var Shop2ButtonMap : [string]button_loud = map{}
    #Creates the player's main UI
    GetLuck():float=
        if:
            luck:= Upgrades["Luck"]
        then:
            return luck.multi
        return 1.0
    CreateUI() : canvas =  
        StackBoxSlot5:=stack_box_slot:
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:=texture_block:
                DefaultImage:= GoldIconTest
                DefaultTint:= Black
                DefaultDesiredSize:= vector2{X:=40.0,Y:=40.0}
        StackBoxSlot6:=stack_box_slot:
            Padding:= margin{Left := 10.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:= overlay:
                Slots:= array:
                    overlay_slot:
                        Widget:=CurrencyTB
        StackBox2:=stack_box{Orientation:= orientation.Horizontal}
        StackBox2.AddWidget(StackBoxSlot5)
        StackBox2.AddWidget(StackBoxSlot6)
        OverlaySlot2:=overlay_slot:
            HorizontalAlignment:= horizontal_alignment.Fill
            VerticalAlignment:= vertical_alignment.Fill
            Widget:=texture_block:
                DefaultImage:= buttonTest
                DefaultTint:= LightGoldenrodYellow
        OverlaySlot1:=overlay_slot:
            HorizontalAlignment:= horizontal_alignment.Left
            VerticalAlignment:= vertical_alignment.Center
            Padding:= margin{Left := 10.0, Top := 10.0, Right := 20.0, Bottom := 15.0}
            Widget:=StackBox2
        Overlay1 := overlay{}
        Overlay1.AddWidget(OverlaySlot2)
        Overlay1.AddWidget(OverlaySlot1)
        StackBoxSlot7:=stack_box_slot:
            HorizontalAlignment := horizontal_alignment.Left
            Widget:=Overlay1
        StackBoxSlot3:=stack_box_slot:
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:=texture_block:
                DefaultImage:= GoldIconTest
                DefaultTint:= Black
                DefaultDesiredSize:= vector2{X:=40.0,Y:=40.0}
        StackBoxSlot4:=stack_box_slot:
            Padding:= margin{Left := 10.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:= overlay:
                Slots:= array:
                    overlay_slot:
                        Widget:=CurrencyWinsTB
        StackBox1:=stack_box{Orientation:= orientation.Horizontal}
        StackBox1.AddWidget(StackBoxSlot3)
        StackBox1.AddWidget(StackBoxSlot4)
        OverlaySlot3:=overlay_slot:
            HorizontalAlignment:= horizontal_alignment.Fill
            VerticalAlignment:= vertical_alignment.Fill
            Widget:=texture_block:
                DefaultImage:= buttonTest
                DefaultTint:= Red
        OverlaySlot4:= overlay_slot:
            Padding:= margin{Left := 10.0, Top := 10.0, Right := 20.0, Bottom := 15.0}
            HorizontalAlignment:= horizontal_alignment.Left
            VerticalAlignment:= vertical_alignment.Center
            Widget:= StackBox1
        StackBoxSlot8:=stack_box_slot:
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:=texture_block:
                DefaultImage:= KillIcon
                DefaultTint:= Black
                DefaultDesiredSize:= vector2{X:=40.0,Y:=40.0}
        StackBoxSlot9:=stack_box_slot:
            Padding:= margin{Left := 10.0, Top := 0.0, Right := 0.0, Bottom := 0.0}
            HorizontalAlignment:= horizontal_alignment.Left
            Widget:= overlay:
                Slots:= array:
                    overlay_slot:
                        Widget:=Currency2TB
        StackBox4:=stack_box{Orientation:= orientation.Horizontal}
        StackBox4.AddWidget(StackBoxSlot3)
        StackBox4.AddWidget(StackBoxSlot4)
        OverlaySlot5:=overlay_slot:
            HorizontalAlignment:= horizontal_alignment.Fill
            VerticalAlignment:= vertical_alignment.Fill
            Widget:=texture_block:
                DefaultImage:= buttonTest
                DefaultTint:= Blue
        OverlaySlot6:= overlay_slot:
            Padding:= margin{Left := 10.0, Top := 10.0, Right := 20.0, Bottom := 15.0}
            HorizontalAlignment:= horizontal_alignment.Left
            VerticalAlignment:= vertical_alignment.Center
            Widget:= StackBox1
        Overlay2:=overlay{}
        Overlay2.AddWidget(OverlaySlot3)
        Overlay2.AddWidget(OverlaySlot4)
        Overlay3:=overlay{}
        Overlay3.AddWidget(OverlaySlot5)
        Overlay3.AddWidget(OverlaySlot6)
        StackBoxSlot2:=stack_box_slot:
            HorizontalAlignment := horizontal_alignment.Left
            Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}
            Widget:=Overlay2
        StackBoxSlot10:=stack_box_slot:
            HorizontalAlignment := horizontal_alignment.Left
            Padding:= margin{Left := 0.0, Top := 10.0, Right := 0.0, Bottom := 0.0}
            Widget:=Overlay3
        StackBox3:=stack_box{Orientation:= orientation.Vertical}
        StackBox3.AddWidget(StackBoxSlot7)
        StackBox3.AddWidget(StackBoxSlot10)
        StackBox3.AddWidget(StackBoxSlot2)
        CanvasSlot1:=canvas_slot:   
            Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.25}, Maximum := vector2{X := 0.0, Y := 0.25}}
            Offsets := margin{Left := 20.0, Top := 0.0, Right := 50.0, Bottom := 45.0}
            Alignment := vector2{X := 0.0, Y := 0.5}
            SizeToContent := true
            Widget := StackBox3
        MyCanvas: canvas = canvas{}
        MyCanvas.AddWidget(CanvasSlot1)
        return MyCanvas
    
    TextPopUp(Reason:string,Amount:float)<suspends>:void =
        EndY:= GetRandomFloat(0.2, 0.8)
        Step:= 15
        var XAnchor:float=0.0
        var startYCord:float= 0.0
        var YCord:float= 0.0
        var ReverseFloat:  float= 0.0
        var Text:message = StringToMessage("Amount")
        var Text1:message = StringToMessage(Reason)
        if:
            GetRandomFloat(0.0, 1.0) >=0.5
        then:
            set XAnchor = GetRandomFloat(0.6,0.8)
        else:
            set XAnchor = GetRandomFloat(0.2,0.4)
        if:
            Amount >= 0.0
        then:
            set Text =StringToMessage("+${UiAmountFormatting(Amount)}")
        else:
            set Text = StringToMessage("{ToTruncatedString(Amount,1)}")
        var PopupText1: text_block = text_block:
            DefaultTextColor := White
            DefaultShadowColor := Black
            DefaultShadowOpacity := 0.0
            DefaultTextOpacity:=0.0
            DefaultText:= Text1
        var PopupText: text_block = text_block:
            DefaultTextColor := White
            DefaultShadowColor := Black
            DefaultShadowOpacity := 0.0
            DefaultTextOpacity:=0.0
            DefaultText:= Text
        if:
            PlayerUI:= GetPlayerUI[Player]
        then:
            set startYCord = EndY-GetRandomFloat(0.05,0.1)
            X:= stack_box{Orientation:= orientation.Vertical}
            StackBoxSlot1:=stack_box_slot:
                Widget:= PopupText1
            StackBoxSlot2:=stack_box_slot:
                Widget:= PopupText
            X.AddWidget(StackBoxSlot1)
            X.AddWidget(StackBoxSlot2)
            CanvasSlot1:=canvas_slot:
                Anchors := anchors{Minimum := vector2{X := XAnchor, Y := startYCord}, Maximum := vector2{X := XAnchor, Y := startYCord}}
                Offsets := margin{Left := 0.0, Top := 0.0, Right := 170.0, Bottom := 0.0}
                Alignment := vector2{X := 0.0, Y := 0.5}
                SizeToContent := false
                ZOrder:= 0
                Widget:= X
            MyCanvas : canvas = canvas{}
            MyCanvas.AddWidget(CanvasSlot1)
            PlayerUI.AddWidget(MyCanvas)
            for(Iteration:= 1..Step):
                Sleep(0.0)
                set YCord = 1.0-EasingOut(startYCord, EndY, Step,Iteration)
                set ReverseFloat = EasingOut(0.0,1.0,Step,Iteration)
                if (Opacity := type{_X:float where 0.000000 <= _X, _X <= 1.000000}[ReverseFloat]):
                    PopupText.SetTextOpacity(Opacity)
                    PopupText1.SetTextOpacity(Opacity)
                    PopupText.SetShadowOpacity(Opacity)
                    PopupText1.SetShadowOpacity(Opacity)
                X.SetVisibility(widget_visibility.Hidden)
                MyCanvas.RemoveWidget(X)
                X.SetVisibility(widget_visibility.Visible)
                MyCanvas.AddWidget(
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := XAnchor, Y := YCord}, Maximum := vector2{X := XAnchor, Y := YCord}}
                        Offsets := margin{Left := 0.0, Top := 0.0, Right := 170.0, Bottom := 0.0}
                        Alignment := vector2{X := 0.0, Y := 0.5}
                        SizeToContent := false
                        Widget := X
                )
            Sleep(1.5)
            for(Iteration:= 1..6):
                Sleep(0.0)
                set ReverseFloat = EasingOut(1.0,0.0,6,Iteration)
                if (Opacity := type{_X:float where 0.000000 <= _X, _X <= 1.000000}[ReverseFloat]):
                    PopupText.SetTextOpacity(Opacity)
                    PopupText1.SetTextOpacity(Opacity)
                    PopupText.SetShadowOpacity(Opacity)
                    PopupText1.SetShadowOpacity(Opacity)
                X.SetVisibility(widget_visibility.Hidden)
                MyCanvas.RemoveWidget(X)
                X.SetVisibility(widget_visibility.Visible)
            PlayerUI.RemoveWidget(MyCanvas)
