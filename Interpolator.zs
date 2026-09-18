class Interpolator
{
    float Target;
    float Speed;
    
    private float m_current;
    
    float Update(float deltaTime)
    {
        return UpdateInternal(deltaTime);
    }
    
    private virtual float UpdateInternal(float deltaTime)
    {
        if (self.Speed == 0)
            self.Speed = 1.0f;
        
        float delta = (self.Target - self.m_current) * (deltaTime * self.Speed * 10);
        
        if (delta < 0.01f && delta > -0.001)
        {
            self.m_current = Target;
        }
        else
        {
            self.m_current += delta;
        }
        
        return m_current;
    }
}