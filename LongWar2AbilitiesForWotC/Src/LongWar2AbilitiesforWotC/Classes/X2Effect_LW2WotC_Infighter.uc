//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_Infighter
//  AUTHOR:  John Lumpkin (Pavonis Interactive), LWotC Team
//  PURPOSE: Sets up dodge, defense and crit resistance bonuses for Infighter
//---------------------------------------------------------------------------------------
class X2Effect_LW2WotC_Infighter extends X2Effect_Persistent config (LW_SoldierSkills);

var config int INFIGHTER_DODGE_BONUS;
var config int INFIGHTER_DEFENSE_BONUS;
var config int INFIGHTER_CRITRES_BONUS;

var config int INFIGHTER_MAX_TILES;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{

    local ShotModifierInfo				ShotInfo;
	local int							Tiles;

	if (Target.IsImpaired(false) || Target.IsBurning() || Target.IsPanicked())
		return;

	Tiles = Attacker.TileDistanceBetween(Target);       
	if (Tiles <= default.INFIGHTER_MAX_TILES + 1)
	{
		if(default.INFIGHTER_DODGE_BONUS > 0)
		{
			ShotInfo.ModType = eHit_Graze;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = default.INFIGHTER_DODGE_BONUS;
			ShotModifiers.AddItem(ShotInfo);
		}

		if(default.INFIGHTER_DODGE_BONUS > 0)
		{
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = default.INFIGHTER_DEFENSE_BONUS;
			ShotModifiers.AddItem(ShotInfo);
		}
		
		if(default.INFIGHTER_CRITRES_BONUS > 0)
		{
			ShotInfo.ModType = eHit_Crit;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = -default.INFIGHTER_CRITRES_BONUS;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="LW2WotC_Infighter"
}
