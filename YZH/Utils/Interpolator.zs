class YZH_Interpolator
{
    float Target;
    float Speed;
    float Current;

    float Step;

    float Update(float deltaTime)
    {
        if (self.Step != 0)
        {
            if (self.Current > self.Target)
            {
                self.Current = max(self.Target, self.Current - self.Step);
            }
            else
            {
                self.Current = min(self.Target, self.Current + self.Step);
            }
        }
        else
        {
            if (self.Speed == 0)
                self.Speed = 1.0f;

            float delta = (self.Target - self.Current) * (deltaTime * (self.Speed * 10));

            if (delta < 0.01f && delta > -0.001)
            {
                self.Current = Target;
            }
            else
            {
                self.Current += delta;
            }
        }

        return self.Current;
    }
}