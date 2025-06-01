
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


Afk_Dev := class(creative_device):
    @editable Seats: []chair_device = array{}
    @editable Main :Game_Manager_Device= Game_Manager_Device{}
    @editable FPC : gameplay_camera_first_person_device = gameplay_camera_first_person_device{}
    AgentExitsEvent: event(agent) = event(agent){}

    OnBegin<override>()<suspends>:void=
        
        for(Seat:Seats):
            Seat.SeatedEvent.Subscribe(AgentEntersFunc)
            Seat.ExitedEvent.Subscribe(AgentExitsFunc)
    AgentEntersFunc(Agent:agent):void=
        if:
            CP:= Main.PlayerMap[player[Agent]]
            CP.Upgrades["Afk Money"].level >=0.0
        then:
            FPC.RemoveFrom(Agent)
            spawn:
                LoopFunc(CP)
        else:
            for(Seat:Seats):
                if:
                    Seat.IsSeated[Agent]
                then:
                    Seat.Eject(Agent)
    AgentExitsFunc(Agent:agent):void=
        AgentExitsEvent.Signal(Agent)
        FPC.AddTo(Agent)
    LoopFunc(CP:PlayerStats)<suspends>:void=
        race:
            AwaitFunc(CP.Player)
            loop:
                Sleep(1.0)
                if:
                    Amount:float= CP.Upgrades["Afk Money"].multi
                then:
                    Main.SubmitCurrency("AFK",CP.Player,Amount)
    AwaitFunc(Agent:agent)<suspends>:void=
        loop:
            Agent1:= AgentExitsEvent.Await()
            if:
                Agent1 = Agent
            then:
                FPC.AddTo(Agent)
                break:
