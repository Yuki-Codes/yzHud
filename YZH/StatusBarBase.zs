#include "YZH/StatusbarAddOn.zs"

class YZH_StatusBarBase : BaseStatusBar
{
    Array<YZH_StatusbarAddOn> m_addons;
    private ui float m_prevDrawTime;

    void RegisterAddon(class<YZH_StatusbarAddOn> type)
    {
        YZH_StatusbarAddOn addOn = YZH_StatusbarAddOn(new(type));
        addOn.Initialize(self);
        m_addons.push(addOn);
    }

    override void Init()
    {
    }

    override void Tick()
    {
        super.Tick();

        for (int i = 0; i < m_addons.Size(); i++)
        {
            m_addons[i].Tick();
        }
    }

    override void Draw(int state, float ticFrac)
    {
        float drawTime = MSTimeF();
        float deltaTime = (drawTime - m_prevDrawTime) / 1000;
        deltaTime = clamp(deltaTime, 0, 0.1);
        m_prevDrawTime = drawTime;

        if (state == HUD_None)
            return;

        BeginHUD();

        for (int i = 0; i < m_addons.Size(); i++)
        {
            m_addons[i].Draw(deltaTime);
        }
    }
}