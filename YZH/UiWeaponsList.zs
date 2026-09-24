class YZH_UiWeaponsList : YZH_UiAddOnBase
{
    private ui Array<YZH_WeaponSlot> m_weaponSlots;
    private ui int m_previewWeaponNumber;
    private ui String m_previewWeaponType;
    private ui int m_selectingWeaponNumber;
    private ui YZH_Interpolator m_selectionScrollOffset;
    private ui bool m_isOpen;

    override void Initialize()
    {
        m_isOpen = false;
        m_previewWeaponNumber = 0;
        m_selectionScrollOffset = new("YZH_Interpolator");
        m_selectionScrollOffset.Speed = 3.0f;

        // Create all slots
        for (int i = 0; i <= 10; i++)
        {
            YZH_WeaponSlot slot = new("YZH_WeaponSlot");
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
            [located, slot, priority] = self.Player.weapons.LocateWeapon(weaponType);

            if (!located)
                continue;

            YZH_WeaponInfo newInfo = new("YZH_WeaponInfo");
            newInfo.Slot = slot;
            newInfo.Priority = priority;
            newInfo.Type = weaponType;

            int numWeaponsInSlot = m_weaponSlots[slot].WeaponTypes.size();

            bool inserted = false;
            for (int i = 0; i < numWeaponsInSlot; i++)
            {
                YZH_WeaponInfo otherInfo = m_weaponSlots[slot].WeaponTypes[i];
                if (otherInfo.Priority < newInfo.Priority)
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
        if (self.Player.mo == null)
            return;

        Array<string> parts;
        event.Name.split(parts, ":");

        if (parts[0] == "YZH")
        {
            if (parts[1] == "SelectWeapon")
            {
                if (self.Player.ReadyWeapon.GetClassName() == parts[2])
                    return;

                Weapon targetWeapon = Weapon(self.Player.mo.findInventory(parts[2]));
                self.Player.pendingWeapon = targetWeapon;
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

                EventHandler.SendNetworkEvent(string.format("YZH:SelectWeapon:%s", m_previewWeaponType));

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
        YZH_WeaponSlot slot = m_weaponSlots[slotIndex];
        Array<YZH_WeaponInfo> validWeapons;
        for (int i = 0; i < slot.WeaponTypes.Size(); i++)
        {
            YZH_WeaponInfo info = slot.WeaponTypes[i];
            if (info.IsValid(self.Player))
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
            YZH_WeaponInfo info = validWeapons[i];
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
    override void Draw(float deltaTime)
    {
        int xPos = (self.GetWidth() / 2) + 200;
        int yPos = (self.GetHeight() / 2);

        Weapon currentWeapon = self.Player.ReadyWeapon;

        int boxHeight = 32;

        int weaponNumber = 0;
        int totalWeapons = 0;
        for (int i = 0; i < 10; i++)
        {
            YZH_WeaponSlot slot = m_weaponSlots[i];

            for (int j = 0; j < slot.WeaponTypes.Size(); j++)
            {
                YZH_WeaponInfo info = slot.WeaponTypes[j];

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
        yPos -= m_selectionScrollOffset.Update(deltaTime);
        yPos += 50;

        for (int i = 0; i < 10; i++)
        {
            YZH_WeaponSlot slot = m_weaponSlots[i];

            for (int i = 0; i < slot.WeaponTypes.Size(); i++)
            {
                YZH_WeaponInfo info = slot.WeaponTypes[i];

                if (!info.Instance)
                    continue;

                if (m_previewWeaponNumber == weaponNumber)
                    m_previewWeaponType = info.Type.GetClassName();

                info.Draw(
                    self,
                    m_previewWeaponNumber == weaponNumber,
                    !m_isOpen,
                    m_selectingWeaponNumber == weaponNumber,
                    xPos,
                    yPos,
                    boxHeight,
                    deltaTime);

                yPos += boxHeight + 2;
                weaponNumber++;
            }
        }
    }
}

class YZH_WeaponSlot
{
    Array<YZH_WeaponInfo> WeaponTypes;
    int Index;
}

class YZH_WeaponInfo
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

    private ui YZH_Interpolator m_offset;
    private ui YZH_Interpolator m_boxAlpha;
    private ui YZH_Interpolator m_iconAlpha;
    private ui YZH_Interpolator m_textAlpha;

    ui void Init()
    {
        m_font = Font.FindFont('SmallFont');
        m_weaponBoxTextureId = TexMan.CheckForTexture("wpnbox");

        m_offset = new ("YZH_Interpolator");
        m_offset.Speed = 3.0f;
        m_boxAlpha = new ("YZH_Interpolator");
        m_boxAlpha.Speed = 3.0f;
        m_iconAlpha = new ("YZH_Interpolator");
        m_iconAlpha.Speed = 3.0f;
        m_textAlpha = new ("YZH_Interpolator");
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
        YZH_UiWeaponsList list,
        bool isPreview,
        bool isHidden,
        bool isSelected,
        int xPos,
        int yPos,
        int height,
        float deltaTime)
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

        int offset = self.m_offset.Update(deltaTime);

        let frameColor = Color(255, 80, 80, 80);
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
            String.Format("%d: %s", self.Slot, self.Name),
            xPos + offset + 3,
            yPos + height - m_font.GetHeight(),
            alpha: self.m_textAlpha.Update(deltaTime));
    }
}