#include "UiAddOn.zs"
#include "Interpolator.zs"

class WeaponsList : UiAddOn
{
    ui Array<WeaponSlot> m_weaponSlots;
    
    ui int m_previewWeaponNumber;
    
    override void Initialize()
    {
        
        m_previewWeaponNumber = -1;
        
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
    
    // Scope: UI
    override bool InputProcess(InputEvent event)
    {
        if (event.type != InputEvent.Type_KeyDown)
            return false;

        if (bindings.GetBinding(event.KeyScan) ~== "weapnext")
        {
            m_previewWeaponNumber++;
            return true;
        }
        else if (bindings.GetBinding(event.KeyScan) ~== "weapprev")
        {
            m_previewWeaponNumber--;
            return true;
        }
        else if (bindings.GetBinding(event.KeyScan) ~== "+attack")
        {
            return true;
        }
        else if (bindings.GetBinding(event.KeyScan) ~== "+altAttack")
        {
            return true;
        }
        
        return false;
    }
    
    // Scope: UI
    override void Draw(float deltaTime)
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
            
            for (int i = 0; i < slot.WeaponTypes.Size(); i++)
            {
                WeaponInfo info = slot.WeaponTypes[i];
                
                if (info.IsValid(player))
                {
                    totalWeapons++;
                }
            }
        }
        
        yPos -= (totalWeapons * boxHeight) / 2;
        
        for (int i = 0; i < 10; i++)
        {
            WeaponSlot slot = m_weaponSlots[i];
            
            for (int i = 0; i < slot.WeaponTypes.Size(); i++)
            {
                WeaponInfo info = slot.WeaponTypes[i];
                
                if (!info.IsValid(player))
                    continue;
                
                info.Draw(
                    self,
                    weaponNumber == m_previewWeaponNumber,
                    deltaTime,
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
    
    private ui TextureId m_weaponBoxTextureId;
    private ui Font m_font;
    
    private ui Interpolator m_offset;
    private ui Interpolator m_boxAlpha;
    private ui Interpolator m_iconAlpha;
    private ui Interpolator m_textAlpha;
    
    ui void Init(Weapon weapon)
    {
        m_font = Font.FindFont('SmallFont');
        m_weaponBoxTextureId = TexMan.CheckForTexture("wpnbox");
        
        m_offset = new ("Interpolator");
        m_boxAlpha = new ("Interpolator");
        m_iconAlpha = new ("Interpolator");
        m_textAlpha = new ("Interpolator");
    
        self.Name = weapon.getTag();
        self.Icon = BaseStatusBar.getInventoryIcon(weapon, BaseStatusBar.DI_AltIconFirst);
    }
    
    ui bool IsValid(PlayerInfo player)
    {
        Weapon weapon = Weapon(player.mo.findInventory(self.Type.GetClassName()));
        if (weapon == null)
            return false;
            
        if(!m_offset)
            Init(weapon);
            
        return true;
    }
    
    ui void Draw(
        WeaponsList list,
        bool isPreview,
        float deltaTime,
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
        
        int offset = self.m_offset.Update(deltaTime);
        
        let framecolor = Color(255, 80, 80, 80);
        list.DrawTexture(
            m_weaponBoxTextureId,
            xPos + offset,
            yPos,
            width: boxWidth,
            height: height,
            alpha: self.m_boxAlpha.Update(deltaTime));
            
        list.DrawTexture(
            self.Icon,
            xPos + offset + 3,
            yPos + (height / 2),
            alpha: self.m_iconAlpha.Update(deltaTime),
            anchor: (0.0, 0.5),
            clipHeight: height - 2);
            
        list.DrawText(
            m_font,
            self.Name,
            xPos + offset + 3,
            yPos + height - m_font.GetHeight(),
            color: Font.CR_Red,
            alpha: self.m_textAlpha.Update(deltaTime));
    }
}