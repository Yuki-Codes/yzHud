#include "UiAddOn.zs"
#include "Interpolator.zs"

class BossBar : UiAddOn
{
    private Array<BossEntry> m_bosses;

    override void Initialize()
    {
    }

    override void Draw(float deltaTime)
    {
        int posY = 0;

        for (int i = 0; i < m_bosses.Size(); i++)
        {
            if (m_bosses[i].IsActive())
                posY += 16;

            m_bosses[i].Draw(self, deltaTime, posY);
        }
    }

    override void WorldTick()
    {
        super.WorldTick();

        for (int i = 0; i < m_bosses.Size(); i++)
        {
            m_bosses[i].WorldTick();
        }
    }

    override void WorldLoaded(WorldEvent event)
    {
        m_bosses.Clear();

        if (!event.IsSaveGame)
            return;

        foreach(Actor actor : ThinkerIterator.Create('Actor'))
        {
            if (actor.bBoss)
            {
                BossEntry entry = new("BossEntry");
                entry.InitializeWorld(actor);
			    m_bosses.Push(entry);
            }
        }
    }

    override void WorldThingSpawned(WorldEvent event)
    {
		if (event.Thing.bBoss)
        {
            BossEntry entry = new("BossEntry");
            entry.InitializeWorld(event.Thing);
			m_bosses.Push(entry);
		}
	}
}

class BossEntry
{
    private Actor m_actor;
    private bool m_isActive;

    private ui TextureId m_barBgTextureId;
    private ui TextureId m_barFgTextureId;
    private ui TextureId m_barFillTextureId;
    private ui Font m_font;

    private ui Interpolator m_value;
    private ui Interpolator m_width;
    private ui Interpolator m_textAlpha;

    play void InitializeWorld(Actor actor)
    {
        self.m_actor = actor;
        self.m_isActive = false;
    }

    ui void InitializeUi()
    {
        m_barBgTextureId = TexMan.CheckForTexture("barbg");
        m_barFgTextureId = TexMan.CheckForTexture("barfg");
        m_barFillTextureId = TexMan.CheckForTexture("barfill");
        m_font = Font.FindFont('SmallFont');

        m_value = new("Interpolator");

        m_width = new("Interpolator");
        m_width.Target = 256;
        m_width.Speed = 0.5f;

        m_textAlpha = new("Interpolator");
        m_textAlpha.Target = 1.0f;
    }

    play void WorldTick()
    {
        if (m_isActive)
        {
            if (m_actor == null
                || m_actor.health <= 0)
            {
                m_isActive = false;
            }
        }
        else
        {
            if (m_actor != null
                && m_actor.target
                && m_actor.target.player
                && m_actor.health > 0

                // CheckSightOrRange is backwards! false means _in sight and in range_
                && !m_actor.CheckSightOrRange(100))
            {
                m_isActive = true;
            }
        }
    }

    bool IsActive()
    {
        return m_isActive;
    }

    ui void Draw(UiAddOn addOn, float deltaTime, int y)
    {
        if (!m_barBgTextureId.IsValid())
            InitializeUi();

        // TODO: Animate
        if (!m_isActive)
            return;

        float barWidth = m_width.Update(deltaTime);

        bool isOpened = barWidth >= m_width.Target - 1;

        double healthRatio = 0;
        if (isOpened)
        {
            healthRatio = m_actor.health / Double(m_actor.SpawnHealth());
            healthRatio = clamp(healthRatio, 0, 1);
            m_value.Target = healthRatio;

            healthRatio = m_value.Update(deltaTime);
        }

        addOn.DrawTexture(
            m_barBgTextureId,
            (addOn.GetWidth() / 2) -  (barWidth / 2),
            y,
            width: barWidth,
            height: 16,
            alpha: 1.0);

        addOn.DrawTexture(
            m_barFillTextureId,
            (addOn.GetWidth() / 2) -  (barWidth / 2) + 2,
            y + 1,
            width: (healthRatio * (barWidth - 4)),
            height: 16,
            alpha: 1.0);

        addOn.DrawTexture(
            m_barFgTextureId,
            (addOn.GetWidth() / 2) - (barWidth / 2),
            y,
            width: barWidth,
            height: 16,
            alpha: 1.0);

        if (isOpened)
        {
            addOn.DrawText(
                m_font,
                m_actor.GetTag(),
                (addOn.GetWidth() / 2),
                y + 2,
                color: Font.CR_White,
                align: 0.5,
                alpha:m_textAlpha.Update(deltaTime));
        }
    }
}