
using { /Fortnite.com/Devices }
using { /Verse.org/Verse }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
<#
Item:= struct<persistable>: 
    Name :string
    Quantity:int

InventoryManager := class():
    #returns index of an item
    Item_Find(Inventory: []Item, ItemName:string):?int =
        for(X->InventoryItem : Inventory):
            if(InventoryItem.Name = ItemName):
                return option{X}
        return false
    #Adds Items to inventory
    Item_add(Inventory: []Item, ItemName:string,ItemQuantity:int): []Item = 
        var index :?int= Item_Find(Inventory,ItemName)
        var NewInventory :[]Item= Inventory
        if:
            NewInventory[index?]
            NewItem := Item{Name := NewInventory[index?].Name, Quantity:= NewInventory[index?].Quantity + ItemQuantity}
            set NewInventory[index?] = NewItem
        else:
            NewItem :Item = Item: 
                Name:= ItemName
                Quantity:=ItemQuantity
            set NewInventory = NewInventory + array{NewItem}
        return NewInventory
    #Checks if Item quantity is higher than given Quantity
    ItemHas(Inventory:[]Item,Name:string,Quantity:int):logic=
        var Index :?int= Item_Find(Inventory,Name)
        if:
            Amount :int= Inventory[Index?].Quantity
            Amount>=Quantity
        then:
            return true
        return false
    #Subtracts Quantity from current Quantity
    ItemSubtract(Inventory:[]Item,Name:string,Quantity:int): []Item =
        var NewInventory :[]Item= Inventory
        var Index :?int= Item_Find(Inventory,Name)
        HasEnough := ItemHas(Inventory, Name, Quantity)
        if:
            HasEnough
            NewInventory[Index?].Quantity =  NewInventory[Index?].Quantity - Quantity
            NewInventory[Index?].Quantity >= 0
            NewInventory.RemoveElement[Index?]
        return NewInventory
    #removes Item
    ItemRemove(ItemName:string,ItemQuantity:int,Inventory:[]Item):[]Item=
        index := Item_Find(Inventory, ItemName)
        if:
            NewInventory := Inventory.RemoveElement[index?]
        then:
            return NewInventory
        return Inventory#>