#include "UiAddOn.zs"
#include "Interpolator.zs"

class WeaponsList : UiAddOn
{
    private ui Array<WeaponSlot> m_weaponSlots;
    private ui int m_previewWeaponNumber;
    private ui String m_previewWeaponType;
    private ui int m_selectingWeaponNumber;
    private ui Interpolator m_selectionScrollOffset;
    private ui bool m_isOpen;
    
    override void Initialize()
    {
        m_isOpen = false;
        m_previewWeaponNumber = 0;
        m_selectionScrollOffset = new("Interpolator");
        m_selectionScrollOffset.Speed = 3.0f;
        
        // Create all slots
        for (int i = 0; i <= 10; i++)
        {
            WeaponSlot slot = new("WeaponSlot");
            slot.Index = i;
            m_weaponSlots.Push(slot);
        }
        
        PlayerInfo player = players[consolePlayer];
        
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
                if (otherInfo.Priority > newInfo.Priority)
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
    
    // Scope: Play
    override void NetworkProcess(ConsoleEvent event)
    {
        if (players[consolePlayer].mo == null)
            return;
        
        Array<string> parts;
        event.Name.split(parts, ":");
            
        if (parts[0] == "yzHud")
        {
            if (parts[1] == "SelectWeapon")
            {
                if (players[consolePlayer].ReadyWeapon.GetClassName() == parts[2])
                    return;
                    
                Weapon targetWeapon = Weapon(players[consolePlayer].mo.findInventory(parts[2]));
                players[consolePlayer].pendingWeapon = targetWeapon;
            }
        }
    }
    
    // Scope: UI
    override bool InputProcess(InputEvent event)
    {
        if (event.type != InputEvent.Type_KeyDown)
            return false;

        if (bindings.GetBinding(event.KeyScan) ~== "weapnext")
        {
            m_selectingWeaponNumber = -1;
            m_previewWeaponNumber++;
            m_isOpen = true;
            return true;
        }
        else if (bindings.GetBinding(event.KeyScan) ~== "weapprev")
        {
            m_selectingWeaponNumber = -1;
            m_previewWeaponNumber--;
            m_isOpen = true;
            return true;
        }
        else
        {
            for (int i = 0; i <= 11; ++i)
            {
                if (bindings.GetBinding(event.KeyScan) ~== string.format("slot %d", i))
                {
                    self.PreviewWeaponSlot(i);
                    return true;
                }
            }
        }
        
        if (m_isOpen)
        {
            if (bindings.GetBinding(event.KeyScan) ~== "+attack")
            {
                m_selectingWeaponNumber = m_previewWeaponNumber;
                m_isOpen = false;
                
                EventHandler.SendNetworkEvent(string.format("yzHud:SelectWeapon:%s", m_previewWeaponType));
                
                return true;
            }
            else if (bindings.GetBinding(event.KeyScan) ~== "+altAttack")
            {
                m_isOpen = false;
                return true;
            }
        }
        
        return false;
    }
    
    private ui void PreviewWeaponSlot(int slotIndex)
    {
        // Get all the valid weapons in this slot
        WeaponSlot slot = m_weaponSlots[slotIndex];
        Array<WeaponInfo> validWeapons;
        for (int i = 0; i < slot.WeaponTypes.Size(); i++)
        {
            WeaponInfo info = slot.WeaponTypes[i];
            if (info.IsValid(players[consolePlayer]))
            {
                validWeapons.push(info);
            }
        }
        
        // Nothing in this slot
        if (validWeapons.Size() <= 0)
            return;
        
        // Find the currently previewed entry
        int previewIndex = -1;
        for (int i = 0; i < validWeapons.Size(); i++)
        {
            WeaponInfo info = validWeapons[i];
            if (info.WeaponNumber == m_previewWeaponNumber)
            {
                previewIndex = i;
                break;
            }
        }
        
        if (previewIndex == -1)
        {
            m_previewWeaponNumber = validWeapons[0].WeaponNumber;
        }
        else
        {
            previewIndex++;
            
            if (previewIndex >= validWeapons.Size())
                previewIndex = 0;
            
            m_previewWeaponNumber = validWeapons[previewIndex].WeaponNumber;
        }
        
        m_isOpen = true;
    }
    
    // Scope: UI
    override void Draw(double ticFrac)
    {
        int xPos = (self.GetWidth() / 2) + 200;
        int yPos = (self.GetHeight() / 2);
        
        PlayerInfo player = players[consolePlayer];
        Weapon currentWeapon = player.ReadyWeapon;
        
        int boxHeight = 32;
        
        int weaponNumber = 0;
        int totalWeapons = 0;
        for (int i = 0; i < 10; i++)
        {
            WeaponSlot slot = m_weaponSlots[i];
            
            for (int j = 0; j < slot.WeaponTypes.Size(); j++)
            {
                WeaponInfo info = slot.WeaponTypes[j];
                
                if (info.IsValid(player))
                {
                    info.WeaponNumber = totalWeapons;
                    totalWeapons++;
                }
            }
        }
        
        if (m_previewWeaponNumber < 0)
            m_previewWeaponNumber = totalWeapons - 1;
            
        if (m_previewWeaponNumber >= totalWeapons)
            m_previewWeaponNumber = 0;
        
        m_selectionScrollOffset.Target = m_previewWeaponNumber * boxHeight;
        
        //yPos -= (totalWeapons * boxHeight) / 2;
        yPos -= m_selectionScrollOffset.Update(ticFrac);
        yPos += 50;
        
        for (int i = 0; i < 10; i++)
        {
            WeaponSlot slot = m_weaponSlots[i];
            
            for (int i = 0; i < slot.WeaponTypes.Size(); i++)
            {
                WeaponInfo info = slot.WeaponTypes[i];
                
                if (!info.Instance)
                    continue;
                    
                if (m_previewWeaponNumber == weaponNumber)
                    m_previewWeaponType = info.Type.GetClassName();
                
                info.Draw(
                    self,
                    m_previewWeaponNumber == weaponNumber,
                    !m_isOpen,
                    m_selectingWeaponNumber == weaponNumber,
                    ticFrac,
                    xPos,
                    yPos,
                    boxHeight);

                yPos += boxHeight + 2;
                weaponNumber++;
            }
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
    String Name;
    TextureID Icon;
    Weapon Instance;
    int WeaponNumber;
    
    private ui TextureId m_weaponBoxTextureId;
    private ui Font m_font;
    
    private ui Interpolator m_offset;
    private ui Interpolator m_boxAlpha;
    private ui Interpolator m_iconAlpha;
    private ui Interpolator m_textAlpha;
    
    ui void Init()
    {
        m_font = Font.FindFont('SmallFont');
        m_weaponBoxTextureId = TexMan.CheckForTexture("wpnbox");
        
        m_offset = new ("Interpolator");
        m_offset.Speed = 3.0f;
        m_boxAlpha = new ("Interpolator");
        m_boxAlpha.Speed = 3.0f;
        m_iconAlpha = new ("Interpolator");
        m_iconAlpha.Speed = 3.0f;
        m_textAlpha = new ("Interpolator");
        m_textAlpha.Speed = 3.0f;
    
        self.Name = self.Instance.getTag();
        self.Icon = BaseStatusBar.getInventoryIcon(self.Instance, BaseStatusBar.DI_AltIconFirst);
    }
    
    ui bool IsValid(PlayerInfo player)
    {
        if (player == null || player.mo == null || self.Type == null)
            return false;
        
        self.Instance = Weapon(player.mo.findInventory(self.Type.GetClassName()));
        if (self.Instance == null)
            return false;
            
        if(!m_font)
            Init();
            
        return true;
    }
    
    ui void Draw(
        WeaponsList list,
        bool isPreview,
        bool isHidden,
        bool isSelected,
        double ticFrac,
        int xPos,
        int yPos,
        int height)
    {   
        if (!m_offset)
            return;
        
        int boxWidth = 128;
        
        self.m_offset.Target = isPreview ? 0 : 25;
        self.m_boxAlpha.Target = isPreview? 1.0 : 0.25;
        self.m_iconAlpha.Target = isPreview? 1.0 : 0.25;
        self.m_textAlpha.Target = isPreview ? 1.0 : 0.0;
        
        if (isHidden)
        {
            self.m_offset.Target = isSelected ? 0 : 50;
            self.m_boxAlpha.Target = 0;
            self.m_iconAlpha.Target = 0;
            self.m_textAlpha.Target = 0;
        }
        
        int offset = self.m_offset.Update(ticFrac);
        
        let framecolor = Color(255, 80, 80, 80);
        list.DrawTexture(
            m_weaponBoxTextureId,
            xPos + offset,
            yPos,
            width: boxWidth,
            height: height,
            alpha: self.m_boxAlpha.Update(ticFrac));
            
        list.DrawTexture(
            self.Icon,
            xPos + offset + 3,
            yPos + (height / 2),
            alpha: self.m_iconAlpha.Update(ticFrac),
            anchor: (0.0, 0.5),
            clipHeight: height - 2);
            
        list.DrawText(
            m_font,
            String.Format("%d: %s", self.Slot, self.Name),
            xPos + offset + 3,
            yPos + height - m_font.GetHeight(),
            color: Font.CR_Red,
            alpha: self.m_textAlpha.Update(ticFrac));
    }
}