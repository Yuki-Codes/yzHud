#include "Gutamatics/Include.zsc"

class InteractHighlight : UiAddOn
{
    const MinDistance = 25;
    const MaxDistance = 1500;
    const PenetrateThickness = 200;
    const GroupDistance = 50;

    private Array<LineInteract> m_interacts;
    private ui YzProjectionCache m_projectionCache;

    override void Initialize()
    {
        m_projectionCache = new("YzProjectionCache");
    }

    override void WorldLoaded(WorldEvent event)
    {
        let player = players[consolePlayer];

        int interactableCount = 0;
        for (int i = 0; i < Level.Lines.Size(); i++)
        {
            Line line = Level.Lines[i];
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                LineInteract interact = new("LineInteract");
                interact.Initialize(line);
                m_interacts.push(interact);
            }
        }

        // group interacts that are close together
        for (int i = 0; i < m_interacts.Size(); i++)
        {
            for (int j = 0; j < m_interacts.Size(); j++)
            {
                m_interacts[i].CheckAreaGroup(m_interacts[j]);
            }
        }
    }

    override void RenderUnderlay(RenderEvent event)
    {
        super.RenderUnderlay(event);

        let player = players[consolePlayer];
        double aspect = Screen.GetWidth() / Screen.GetHeight();
        m_projectionCache.CalculateMatrices(
            aspect,
            player.Fov,
            event.ViewPos,
            event.ViewAngle,
            event.ViewPitch,
            event.ViewRoll);

        m_projectionCache.CalculateMatrices(
            Screen.GetAspectRatio(),
            event.camera.player ? event.camera.player.fov : event.camera.cameraFOV,
            event.viewPos,
            event.viewAngle,
            event.viewPitch,
            event.viewRoll);

        for (int i = 0; i < m_interacts.Size(); i++)
        {
            m_interacts[i].Draw(
                self.Player,
                event.viewPos,
                m_projectionCache.worldToClip,
                m_deltaTime);
        }
    }

    override void WorldTick()
    {
        super.WorldTick();

        for (int i = 0; i < m_interacts.Size(); i++)
        {
            m_interacts[i].Tick(self.Player);
        }

        for (int i = 0; i < m_interacts.Size(); i++)
        {
            m_interacts[i].TickAreaGroup(self.Player);
        }
    }
}


class LineInteract
{
    private Line m_line;
    private Array<LineInteract> m_areaGroup;
    private Vector3 m_interactPosition;
    private ui TextureId m_highlight;
    private ui Interpolator m_alpha;

    private play bool m_canSee;
    private play int m_distanceFromPlayer;
    private play bool m_isClosestInGroup;
    private play bool m_shouldDraw;

    void Initialize(Line line)
    {
        m_line = line;

        Vector2 a = m_line.v1.p;
        Vector2 b = m_line.v2.p;
        Vector2 pos2d = (a + b) / 2;

        m_interactposition.x = pos2d.x;
        m_interactposition.y = pos2d.y;

        m_interactposition.z = line.FrontSector.FloorPlane.ZatPoint(pos2d);
        m_interactposition.z += 32;
    }

    void CheckAreaGroup(LineInteract other)
    {
        Vector3 delta = Level.Vec3Diff(m_interactposition, other.m_interactposition);
        if (delta.Length() < InteractHighlight.GroupDistance)
        {
            m_areaGroup.push(other);
        }
    }

    ui void UiInitialize()
    {
        m_highlight = TexMan.CheckForTexture("interact");
        m_alpha = new("Interpolator");
    }

    play void Tick(PlayerInfo player)
    {
        m_canSee = CanSee(player);
    }

    play void TickAreaGroup(PlayerInfo player)
    {
        if (!m_canSee)
        {
            m_shouldDraw = false;
            return;
        }

        LineInteract bestInteract = self;
        int bestDistance = self.m_distanceFromPlayer;
        for (int i = 0; i < m_areaGroup.Size(); i++)
        {
            if (m_areaGroup[i].m_canSee && m_areaGroup[i].m_distanceFromPlayer < bestDistance)
            {
                bestDistance = m_areaGroup[i].m_distanceFromPlayer;
                bestInteract = m_areaGroup[i];
            }
        }

        m_shouldDraw = bestInteract == self;
    }

    play bool CanSee(PlayerInfo player)
    {
        Vector3 startpos = player.mo.pos;
        startPos.z = player.viewz;
        Vector3 dir = Level.Vec3Diff(startpos, m_interactposition);
        m_distanceFromPlayer = dir.Length();
        dir = dir.Unit();

        // within range
        if (m_distanceFromPlayer < InteractHighlight.MinDistance || m_distanceFromPlayer > InteractHighlight.MaxDistance)
            return false;

        // sector has been seen
        if (m_line.FrontSector != null && !(m_line.FrontSector.MoreFlags & Sector.SECMF_DRAWN))
            return false;

        // Line of Sight to the wall
        FLineTraceData tr;
        bool hit = player.mo.LineTrace(
            atan2(dir.y, dir.x),
            m_distanceFromPlayer + 100,
            asin(-dir.z),
            offsetz: player.viewz - player.mo.pos.z,
            data: tr);

        if (!hit)
            return false;

        // See through thin walls
        Vector3 hitOffset = Level.Vec3Diff(tr.HitLocation, m_interactposition);
        if (hitOffset.Length() < InteractHighlight.PenetrateThickness)
            return true;

        // seeing the right wall
        if (tr.HitType == TRACE_HitWall && tr.HitLine == m_line)
            return true;

        // seeing the wrong wall
        return false;
    }

    ui void Draw(PlayerInfo player, Vector3 viewPos, YzMatrix4 worldToClip, float deltaTime)
    {
        if (m_line == null)
            return;

        if (m_line.special == 0)
            return;

        if (m_alpha == null)
        {
            self.UiInitialize();
        }

        m_alpha.Target = m_shouldDraw ? 1.0 : 0.0;

        Vector3 ndcPos = worldToClip.multiplyVector3(m_interactPosition);
        float alpha = m_alpha.Update(deltaTime);
        if (abs(ndcPos.x) <= 1.0 && abs(ndcPos.y) <= 1.0 && abs(ndcPos.z) <= 1.0)
        {
            Vector2 screenPos = YzGlobalMaths.NDCToViewport(ndcPos);

            Screen.DrawTexture(
                m_highlight,
                false,
                screenPos.x,
                screenPos.y,
                DTA_Alpha, alpha);
        }
    }
}