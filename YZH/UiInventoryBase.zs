class YZH_UiInventoryBase : YZH_UiAddOnBase
{
    private ui Array<YZH_InventoryEntry> m_items;

    ui void AddItem(class<Inventory> type)
    {
        YZH_InventoryEntry entry = new("YZH_InventoryEntry");
        entry.Initialize(self, type);
        m_items.push(entry);
    }

    protected ui void DrawBar(float deltaTime, int x, int y, int direction = 1)
    {
        for (int i = 0; i < m_items.Size(); i++)
        {
            if (!m_items[i].IsValid())
                continue;

            Vector2 anchor = (0, 0);
            if (direction == -1)
                anchor = (1, 0);

            int width = m_items[i].Draw(self, deltaTime, x, y, anchor);
            x += (width + 6) * direction;
        }
    }

    override void Tick()
    {
        if (self.Player == null || self.Player.mo == null)
            return;

        for (int i = 0; i < m_items.Size(); i++)
        {
            m_items[i].Tick(self);
        }
    }

    virtual ui int GetItemValue(Inventory item)
    {
        return 0;
    }
}

class YZH_InventoryEntry ui
{
    private class<Inventory> m_itemClass;
    private Inventory m_item;
    private ui TextureId m_icon;
    private ui Font m_font;
    private ui YZH_Interpolator m_xPos;
    private ui YZH_Interpolator m_alpha;

    void Initialize(YZH_UiInventoryBase uiAddOn, class<Inventory> itemClass)
    {
        m_itemClass = itemClass;

        m_font = Font.FindFont('SmallFont');

        m_xPos = new("YZH_Interpolator");
        m_xPos.Current = uiAddOn.GetWidth() / 2;
        m_xPos.Speed = 0.5f;

        m_alpha = new("YZH_Interpolator");
        m_alpha.Current = 0.0f;
        m_alpha.Target = 1.0f;
    }

    void Tick(YZH_UiInventoryBase uiAddOn)
    {
        Inventory item = uiAddOn.Player.mo.FindInventory(m_itemClass);
        if (item != null && m_item == null)
        {
            m_item = item;
            m_icon = GetIcon(m_item);
        }
        else if (item == null && m_item != null)
        {
            Console.Printf("item lost");
            m_item == null;
            m_xPos.Current = uiAddOn.GetWidth() / 2;
            m_alpha.Current = 0.0f;
        }
    }

    bool IsValid()
    {
        return m_item != null && m_icon.IsValid();
    }

    int Draw(YZH_UiInventoryBase uiAddOn, float deltaTime, int x, int y, Vector2 anchor)
    {
        m_xPos.Target = x;

        Vector2 iconSize = uiAddOn.DrawTexture(
            m_icon,
            m_xPos.Update(deltaTime),
            y,
            alpha:m_alpha.Update(deltaTime),
            height: 16,
            anchor: anchor);

        int value = uiAddOn.GetItemValue(m_item);

        if (value != 0)
        {
            int textPos = m_xPos.Current + (iconSize.x * (1 - anchor.x));
            uiAddOn.DrawText(
                m_font,
                String.Format("%d", value),
                textPos,
                y + 10,
                alpha:m_alpha.Current,
                align: 1);
        }

        return iconSize.x;
    }

    private TextureID GetIcon(Inventory item)
    {
        if (item.GetClass() == "PowerIronFeet"
            || item.GetClassName() == "PowerDimIronFeet")
            return TexMan.CheckForTexture("rad");
            //return TexMan.CheckForTexture("PS18A0");

        if (item.GetClass() == "PowerInvisibility")
            return TexMan.CheckForTexture("PINSA0");

        if (item.GetClass() == "PowerInvulnerable")
            return TexMan.CheckForTexture("PINVA0");

        if (item.GetClass() == "PowerStrength")
            return TexMan.CheckForTexture("PSTRA0");

        if (item.GetClass() == "PowerLightAmp")
            return TexMan.CheckForTexture("PVISA0");

        // if (item.GetClass() == "PowerFlight")

        return item.SpawnState.GetSpriteTexture(0);
    }
}