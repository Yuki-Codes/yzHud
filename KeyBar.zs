#include "alignments.zs"

class KeyBar : UiAddOn
{
    private ui Array<KeyEntry> m_keys;

    override void Initialize()
    {
        for (int i = 0; i < Key.GetKeyTypeCount(); i++)
        {
            let entry = new("KeyEntry");
            entry.Initialize(self, Key.GetKeyType(i));
            m_keys.push(entry);
        }
    }

    override void Draw(float deltaTime)
    {
        int x = (self.GetWidth() / 2) + 65;
        int y = self.GetHeight() - 25;
        for (int i = 0; i < m_keys.Size(); i++)
        {
            if (!m_keys[i].IsValid())
                continue;

            m_keys[i].Draw(self, deltaTime, x, y);
            x += 17;
        }
    }

    override void Tick()
    {
        if (self.Player == null || self.Player.mo == null)
            return;

        for (int i = 0; i < m_keys.Size(); i++)
        {
            m_keys[i].Tick(self);
        }
    }
}

class KeyEntry ui
{
    private class<Key> m_keyClass;
    private Key m_key;
    private ui TextureId m_icon;
    private ui Interpolator m_xPos;
    private ui Interpolator m_yPos;
    private ui Interpolator m_scale;
    private ui Interpolator m_alpha;

    void Initialize(UiAddOn uiAddOn, class<Key> keyClass)
    {
        m_keyClass = keyClass;

        m_xPos = new("Interpolator");
        m_xPos.Current = uiAddOn.GetWidth() / 2;
        m_xPos.Speed = 0.75f;

        m_yPos = new("Interpolator");
        m_yPos.Current = uiAddOn.GetHeight() / 2;
        m_yPos.Speed = 0.75f;

        m_scale = new("Interpolator");
        m_scale.Target = 1.0;
        m_scale.Current = 4.0;

        m_alpha = new("Interpolator");
        m_alpha.Current = 0.0f;
        m_alpha.Target = 1.0f;
    }

    void Tick(UiAddOn uiAddOn)
    {
        Key key = Key(uiAddOn.Player.mo.FindInventory(m_keyClass));
        if (key != null && m_key == null)
        {
            m_key = key;
            m_icon = GetKeyIcon(m_key);
        }
        else if (key == null && m_key != null)
        {
            Console.Printf("key lost");
            m_key == null;
            m_xPos.Current = uiAddOn.GetWidth() / 2;
            m_yPos.Current = uiAddOn.GetHeight() / 2;
            m_scale.Current = 4.0;
            m_alpha.Current = 0.0f;
        }
    }

    bool IsValid()
    {
        return m_key != null && m_icon.IsValid();
    }

    void Draw(UiAddOn uiAddOn, float deltaTime, int x, int y)
    {
        m_xPos.Target = x;
        m_yPos.Target = y;

        uiAddOn.DrawTexture(
            m_icon,
            m_xPos.Update(deltaTime),
            m_yPos.Update(deltaTime),
            scale:m_scale.Update(deltaTime),
            alpha:m_alpha.Update(deltaTime));
    }

    private TextureID GetKeyIcon(Key key)
    {
        if (key.GetClass() == "RedCard")
            return TexMan.CheckForTexture("RKEYA0");

        if (key.GetClass() == "BlueCard")
            return TexMan.CheckForTexture("BKEYA0");

        if (key.GetClass() == "YellowCard")
            return TexMan.CheckForTexture("YKEYA0");

        if (key.GetClass() == "RedSkull")
            return TexMan.CheckForTexture("RSKUA0");

        if (key.GetClass() == "BlueSkull")
            return TexMan.CheckForTexture("BSKUA0");

        if (key.GetClass() == "YellowSkull")
            return TexMan.CheckForTexture("YSKUA0");

        Console.Printf("No icon for key: %s", key.GetClassName());
        return -1;
    }
}