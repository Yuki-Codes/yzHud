#include "alignments.zs"

class InteractPrompt : UiAddOn
{
    Font m_font;

    private ui PromptDetector m_tracer;
    private ui String m_promptText;

    private ui Interpolator m_alpha;

    override void Initialize()
    {
        m_alpha = new("Interpolator");

        let [useKey1, useKey2] = bindings.GetKeysForCommand("+use");
		String keyname = bindings.NameKeys(useKey1, 0);
        m_promptText = String.Format("[%s]",  keyname);
    }

    // Scope: UI
    override void Draw(float deltaTime)
    {
        float alpha = m_alpha.Update(deltaTime);

        if (alpha > 0)
        {
            self.DrawText(
                m_font,
                m_promptText,
                -1,
                32,
                alpha: alpha);

            self.DrawTexture(
                TexMan.CheckForTexture("interact"),
                0,
                0,
                alpha * 0.75);
        }
    }

    override void Tick()
    {
        let mo = player.mo;

		// Do nothing if this player is a voodoo doll, or is dead:
		if (!mo || mo.health <= 0 || !mo.player || !mo.player.mo || mo.player.mo != mo)
            return;

        if (m_tracer == null)
            m_tracer = new('PromptDetector');

		// Fire from player's screen center:
		Vector3 start = (mo.pos.xy, player.viewz);
		Vector3 dir = (Actor.AngleToVector(mo.angle, cos(mo.pitch)), -sin(mo.pitch));
		m_tracer.Trace(
            start,
            mo.cursector,
            dir,
            mo.userange,
            traceflags: 0,
            wallmask: 0,
            ignore: mo);

        m_alpha.Target = 0;
		if (m_tracer.results.HitType == TRACE_HitWall)
		{
            let line = m_tracer.results.HitLine;
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                m_alpha.Target = 1.0;
            }
        }
    }
}

class PromptDetector : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		switch (results.HitType)
		{
			case TRACE_HitActor:
			case TRACE_HitFloor:
			case TRACE_HitCeiling:
			case TRACE_HitWall:
            {
                if (results.HitLine)
                {
                    if (results.HitLine.activation == SPAC_Use
                        || results.HitLine.activation == SPAC_UseThrough)
                    {
				        return TRACE_Stop;
                    }
                }
            }
		}

		return TRACE_Skip;
	}
}