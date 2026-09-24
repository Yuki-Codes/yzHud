class PickupView : UiAddOn
{
    Array<PickupEntry> m_entries;
    private bool m_needsRehook;

    private ui int m_lastPickupOffset;
    static const int PickupOffsets[] =
    {
        24, 2, 22, 15, 5, -20, 31, 5, 12, -34, -20, 9, 11, 0, -5, 4, -14, 14, 7, 3, -1, 5, -19, 3, -13, -12, 26, 7, -13, 15, -16, -10, 16, -16, 11, -9, 10, -8, -20, 2, -3, -1, 1, -18, -5, 15, -12, 25, 5, -2
    };

    ui int GetNextOffset()
    {
        m_lastPickupOffset++;
        if (m_lastPickupOffset >= 50)
            m_lastPickupOffset = 0;

        return PickupOffsets[m_lastPickupOffset];
    }

    override void WorldLoaded(WorldEvent event)
	{
        m_needsRehook = true;

        Actor player = players[consolePlayer].mo;
        player.TakeInventory("PickupViewHookItem", int.max);
	}

    override void RenderUnderlay(RenderEvent event)
    {
        super.RenderUnderlay(event);

        for (int i = 0; i < m_entries.Size(); i++)
        {
            m_entries[i].Draw(self, m_deltaTime);
        }
    }

    override void WorldTick()
    {
        super.WorldTick();

        for (int i = m_entries.Size() - 1; i >= 0; i--)
        {
            if (m_entries[i].IsDone)
            {
                m_entries.Delete(i);
            }
        }
    }

    void OnItemPickup(Inventory item)
    {
        m_needsRehook = true;

        PickupEntry entry = new("PickupEntry");
        entry.Item = item;
        entry.Icon = item.SpawnState.GetSpriteTexture(0);
        entry.Type = item.GetClass();
        m_entries.Push(entry);
    }
}

class PickupViewHookItem : Inventory
{
    PickupView AddOn;

	Default
	{
		inventory.maxamount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.PERSISTENTPOWER
	}

	override bool HandlePickup(Inventory item)
	{
        // will this item actually get collected?
        for (let probe = Owner.Inv; probe != NULL; probe = probe.Inv)
        {
            Inventory otherItem = probe;

            if (otherItem.GetClass() == item.GetClass())
            {
                if (otherItem.Amount >= otherItem.MaxAmount - 1 && !sv_unlimited_pickup)
                {
                    return false;
                }
            }

            Ammo ammoitem = Ammo(otherItem);
            if (ammoitem && ammoitem.GetParentAmmo() == ammoitem.GetClass())
            {
                if (ammoitem.Amount >= ammoitem.MaxAmount && sv_unlimited_pickup)
                {
                    return false;
                }
            }
        }

        self.AddOn.OnItemPickup(item);
		return super.HandlePickup(item);
	}
}

class PickupEntry
{
    TextureId Icon;
    class<Inventory> Type;
    Inventory Item;

    bool IsDone;

    private ui bool m_isInitialized;
    private Interpolator m_positionX;
    private Interpolator m_positionY;
    private Interpolator m_scale;

    ui void Draw(PickupView addOn, float deltaTime)
    {
        if (!m_isInitialized)
        {
            m_positionY = new("Interpolator");
            m_positionY.Current = addOn.GetHeight() - 200;
            m_positionY.Target = addOn.GetHeight();
            m_positionY.Speed = 0.5;

            m_positionX = new("Interpolator");
            m_positionX.Current = (addOn.GetWidth() / 2) + addOn.GetNextOffset();
            m_positionX.Target = addOn.GetWidth() / 2;
            m_positionX.Speed = 0.5;

            m_scale = new("Interpolator");
            m_scale.Current = 4;
            m_scale.Target = 2;
            m_scale.Speed = 0.5;

            m_isInitialized = true;
        }

        addOn.DrawTexture(
            self.Icon,
            m_positionX.Update(deltaTime),
            m_positionY.Update(deltaTime),
            scale:m_scale.Update(deltaTime),
            anchor: (0.5, 0));

        if (m_positionY.Current >= m_positionY.Target)
        {
            self.IsDone = true;
        }
    }
}