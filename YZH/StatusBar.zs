#include "YZH/StatusBarBase.zs"
#include "YZH/Character.zs"

class YZH_StatusBar : YZH_StatusBarBase
{
    override void Init()
    {
        RegisterAddon("YZH_Character");
    }
}