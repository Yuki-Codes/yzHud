#include "alignments.zs"

class WeaponsList ui
{
    YzHud m_hud;
    HUDFont m_font;
    
    Array<WeaponSlot> m_weaponSlots;
    
    void Init(PlayerInfo player)
    {
        // Create all slots
        for (int i = 0; i <= 10; i++)
        {
            WeaponSlot slot = new("WeaponSlot");
            slot.Index = i;
            m_weaponSlots.Push(slot);
        }
        
        // Thanks to Gearbox.
        // Find every weapon and sort the slots
        foreach (actorClass : AllActorClasses)
        {
            class<Weapon> weaponType = (class<Weapon>)(actorClass);

            if (weaponType == NULL || weaponType == "Weapon")
                continue;
                
            bool located;
            int slot;
            int priority;
            [located, slot, priority] = player.weapons.LocateWeapon(weaponType);
            
            if (!located)
                continue;
                
            WeaponInfo newInfo = new("WeaponInfo");
            newInfo.Slot = slot;
            newInfo.Priority = priority;
            newInfo.Type = weaponType;
            
            int numWeaponsInSlot = m_weaponSlots[slot].WeaponTypes.size();
            
            bool inserted = false;
            for (int i = 0; i < numWeaponsInSlot; i++)
            {
                WeaponInfo otherInfo = m_weaponSlots[slot].WeaponTypes[i];
                if (otherInfo.Priority <= newInfo.Priority)
                {
                    m_weaponSlots[slot].WeaponTypes.Insert(i, newInfo);
                    inserted = true;
                    break;
                }
            }
            
            if (!inserted)
            {
                m_weaponSlots[slot].WeaponTypes.Push(newInfo);
            }
        }
    }
        
    void Draw(PlayerInfo player, double ticFrac)
    {
        int xPos = -200; // TODO: Aspect ratio?
        int yPos = 0;
        
        for (int i = 0; i < 10; i++)
        {
            WeaponSlot slot = m_weaponSlots[i];
            
            m_hud.DrawString(
                m_font,
                String.Format("%d: ", i),
                (xPos, yPos),
                VerticalAlignment.Center | HorizontalAlignment.Right | TextAlignment.Left,
                translation: Font.CR_WHITE);
                
            xPos += 10;
            
            for (int i = 0; i < slot.WeaponTypes.Size(); i++)
            {
                WeaponInfo info = slot.WeaponTypes[i];
                Weapon weapon = Weapon(player.mo.findInventory(info.Type.GetClassName()));
                
                if (weapon == null)
                    continue;
                
                m_hud.DrawString(
                    m_font,
                    String.Format("%s", info.Type.GetClassName()),
                    (xPos, yPos),
                    VerticalAlignment.Center | HorizontalAlignment.Right | TextAlignment.Left,
                    translation: Font.CR_WHITE);
                    
                xPos += 100;
            }
            
            yPos += 20;
            xPos = -200;
        }
        
        /*
        for (let iitem = player.mo.Inv; iitem != NULL; iitem = iitem.Inv)
		{
            Weapon weapon = Weapon(iitem);
            if (weapon)
			{
                String name = weapon.getTag();
                TextureID icon = BaseStatusBar.getInventoryIcon(weapon, BaseStatusBar.DI_AltIconFirst);
                
                m_hud.DrawString(
                    m_font,
                    String.Format("%s", name),
                    (xPos, yPos),
                    VerticalAlignment.Center | HorizontalAlignment.Right | TextAlignment.Left,
                    translation: Font.CR_WHITE);
                    
                yPos += 32;
            }
        }*/
    }
    
    void Tick(PlayerInfo player)
    {
        if (m_weaponSlots.Size() == 0)
        {
            self.Init(player);
        }
    }
}

class WeaponSlot
{
    Array<WeaponInfo> WeaponTypes;
    int Index;
}

class WeaponInfo
{
    class<Weapon> Type;
    int Slot;
    int Priority;
}