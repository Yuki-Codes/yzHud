class YZH_UiPickupEffect : YZH_UiAddOnBase
{
    Array<YZH_PickupEntry> m_entries;

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

    override void WorldThingDestroyed(WorldEvent event)
    {
        Inventory item = Inventory(event.Thing);
        if (item)
        {
            OnItemPickup(item);
        }
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
        YZH_PickupEntry entry = new("YZH_PickupEntry");
        entry.Item = item;
        entry.Icon = item.SpawnState.GetSpriteTexture(0);
        entry.Type = item.GetClass();
        m_entries.Push(entry);
    }
}

class YZH_PickupEntry
{
    TextureId Icon;
    class<Inventory> Type;
    Inventory Item;

    bool IsDone;

    private ui bool m_isInitialized;
    private YZH_Interpolator m_positionX;
    private YZH_Interpolator m_positionY;
    private YZH_Interpolator m_scale;
    private YZH_Interpolator m_alpha;

    ui void Draw(YZH_UiPickupEffect addOn, float deltaTime)
    {
        if (!m_isInitialized)
        {
            m_positionY = new("YZH_Interpolator");
            m_positionY.Current = addOn.GetHeight() - 200;
            m_positionY.Target = addOn.GetHeight();
            m_positionY.Speed = 0.5;

            m_positionX = new("YZH_Interpolator");
            m_positionX.Current = (addOn.GetWidth() / 2) + addOn.GetNextOffset();
            m_positionX.Target = addOn.GetWidth() / 2;
            m_positionX.Speed = 0.5;

            m_scale = new("YZH_Interpolator");
            m_scale.Current = 4;
            m_scale.Target = 2;
            m_scale.Speed = 0.5;

            m_alpha = new("YZH_Interpolator");
            m_alpha.Current = 1;
            m_alpha.Target = 0;
            m_alpha.Speed = 2;

            m_isInitialized = true;
        }

        m_positionX.Update(deltaTime);
        m_positionY.Update(deltaTime);
        m_scale.Update(deltaTime);

        if (m_positionY.Current > addOn.GetHeight() - 64)
            m_alpha.Update(deltaTime);

        addOn.DrawTexture(
            self.Icon,
            m_positionX.Current,
            m_positionY.Current,
            scale:m_scale.Current,
            anchor: (0.5, 0),
            alpha: m_alpha.Current);

        if (m_positionY.Current >= m_positionY.Target)
        {
            self.IsDone = true;
        }
    }
}