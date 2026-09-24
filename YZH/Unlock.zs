// Big thanks to Nobody Told Me About id for pretty much all of this
//https://github.com/localins/NTMAi/blob/898b01ff674759e36ee31897b74b8a9f937411ed/zscript/main/ntmai.txt#L447

class YZH_Unlock : StaticEventHandler
{
    private int m_pendingDoorDelay;
    private Line m_pendingDoor;

    override void WorldLinePreActivated(WorldEvent event)
    {
        if (event.Thing != Players[consolePlayer].mo)
            return;

        if (event.ActivationType != SPAC_Use)
            return;

		// If this is a locked door, check if we can play a keycard animation
		if (event.activatedLine.special != 13)
            return;

        bool isUnlocking = TryUnlockDoor(Players[consolePlayer], event.activatedLine.args[3]);
        if (isUnlocking)
        {
            // Queue this door so we can open it after the animation
            m_pendingDoor = event.activatedLine;
            m_pendingDoorDelay = 24;
            event.shouldActivate = false;
        }
    }

    override void WorldTick()
    {
        if (m_pendingDoorDelay > 0)
        {
            m_pendingDoorDelay--;

            if (m_pendingDoorDelay <= 0)
            {
                m_pendingDoor.Activate(Players[consolePlayer].mo, 1, SPAC_Use);
                m_pendingDoor = null;
            }
        }

    }

    private bool TryUnlockDoor(PlayerInfo player, int doorType)
    {
        switch (doorType)
        {
            case 1: return TryUseKey(player, "RedCard");
            case 2: return TryUseKey(player, "BlueCard");
            case 3: return TryUseKey(player, "YellowCard");
            case 4: return TryUseKey(player, "RedSkull");
            case 5: return TryUseKey(player, "BlueSkull");
            case 6: return TryUseKey(player, "YellowSkull");
            case 100: return TryUseKey(player, "RedCard") || TryUseKey(player, "RedSkull")
                    || TryUseKey(player, "BlueCard") || TryUseKey(player, "BlueSkull")
                    || TryUseKey(player, "YellowCard") || TryUseKey(player, "YellowSkull");

            case 129:
            case 132: return TryUseKey(player, "RedCard") || TryUseKey(player, "RedSkull");
            case 130:
            case 133: return TryUseKey(player, "BlueCard") || TryUseKey(player, "BlueSkull");
            case 131:
            case 134: return TryUseKey(player, "YellowCard") || TryUseKey(player, "YellowSkull");
        }

        return false;
    }

    private class<YZH_KeyWeapon> GetKeyWeapon(class<Key> key)
    {
        if (key == "RedCard") return "YZH_KeyWeapon_RedCard";
        if (key == "BlueCard") return "YZH_KeyWeapon_BlueCard";
        if (key == "YellowCard") return "YZH_KeyWeapon_YellowCard";
        if (key == "RedSkull") return "YZH_KeyWeapon_RedSkull";
        if (key == "BlueSkull") return "YZH_KeyWeapon_BlueSkull";
        if (key == "YellowSkull") return "YZH_KeyWeapon_YellowSkull";
        return null;
    }

    private bool TryUseKey(PlayerInfo player, class<Key> keyType)
    {
		if (!player.mo.CountInv(keyType))
            return false;

        // Still holding a key
        if (player.readyWeapon is "YZH_KeyWeapon")
            return false;

        Weapon prevWeapon = player.readyWeapon;

        // Give the player the key weapon
        class<YZH_KeyWeapon> keyWeaponType = GetKeyWeapon(keyType);
        player.mo.A_GiveInventory(keyWeaponType);
        YZH_KeyWeapon keyWeapon = YZH_KeyWeapon(player.mo.FindInventory(keyWeaponType));
        if (!keyWeapon)
            return false;

        // bring up the key weapon
        keyWeapon.prevWeapon = prevWeapon.GetClass();
        player.pendingWeapon = keyWeapon;

        // we're unlocking.
        return true;
	}
}

class YZH_KeyWeapon : Weapon
{
	class<Weapon> prevWeapon;

	Default
    {
		Tag "Hold on...";
		Weapon.SlotNumber 0;

		+Weapon.CheatNotWeapon
		+Weapon.No_Auto_Switch
		+Weapon.NoAlert
		+Inventory.Undroppable
		+Inventory.Untossable
	}

	States
    {
		Select:
		Ready:
		Fire:
			NRKE A 0;
			Goto Animation;

		Animation:
			#### A 0 A_WeaponOffset(0, 131);
			#### ######### 1 A_WeaponOffset(0, -11, WOF_Add);
			#### B 1 A_StartSound("misc/k_pkup");
			#### ######### 1 Bright;
			#### ######### 1 Bright A_WeaponOffset(0, 11, WOF_Add);

		Deselect:
			NRKE B 0 {
				A_SelectWeapon(invoker.prevWeapon, SWF_SelectPriority);
				A_TakeInventory(invoker.GetClassName());
			}

			Stop;
	}
}

class YZH_KeyWeapon_RedCard : YZH_KeyWeapon
{
}

class YZH_KeyWeapon_YellowCard : YZH_KeyWeapon
{
	States
    {
		Select:
		Deselect:
		Ready:
		Fire:
			NYKE A 0;
			Goto Animation;
	}
}

class YZH_KeyWeapon_BlueCard : YZH_KeyWeapon
{
	States
    {
		Select:
		Deselect:
		Ready:
		Fire:
			NBKE A 0;
			Goto Animation;
	}
}

class YZH_KeyWeapon_RedSkull : YZH_KeyWeapon
{
	States
    {
		Select:
		Deselect:
		Ready:
		Fire:
			NRSK A 0;
			Goto Animation;
	}
}

class YZH_KeyWeapon_YellowSkull : YZH_KeyWeapon
{
	States
    {
		Select:
		Deselect:
		Ready:
		Fire:
			NYSK A 0;
			Goto Animation;
	}
}

class YZH_KeyWeapon_BlueSkull : YZH_KeyWeapon
{
	States
    {
		Select:
		Deselect:
		Ready:
		Fire:
			NBSK A 0;
			Goto Animation;
	}
}