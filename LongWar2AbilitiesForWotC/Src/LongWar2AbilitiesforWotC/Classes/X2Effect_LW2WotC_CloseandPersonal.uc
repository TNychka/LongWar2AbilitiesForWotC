//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_CloseandPersonal
//  AUTHOR:  John Lumpkin (Pavonis Interactive), LWotC Team
//  PURPOSE: Sets up range-based modifiers for Close and Personal perk
//--------------------------------------------------------------------------------------- 

class X2Effect_LW2WotC_CloseandPersonal extends X2Effect_Persistent config (LW_SoldierSkills);

var config array<int> CRITBOOST;
var config array<int> AIMBOOST;
var config array<int> DEFENSEBOOST;
var config array<int> DODGEBOOST;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local int Tiles;
    local XComGameState_Item SourceWeapon;
    local ShotModifierInfo ShotInfo;

    SourceWeapon = AbilityState.GetSourceWeapon();    
    if(SourceWeapon != none)
    {
        Tiles = Attacker.TileDistanceBetween(Target);       
        if(CRITBOOST.Length > 0)
        {
            if(Tiles < CRITBOOST.Length)
            {
                ShotInfo.Value = CRITBOOST[Tiles];
            }            
            else //Use last value
            {
                ShotInfo.Value = CRITBOOST[CRITBOOST.Length - 1];
            }
            ShotInfo.ModType = eHit_Crit;
            ShotInfo.Reason = FriendlyName;
            ShotModifiers.AddItem(ShotInfo);
        }
		if(AIMBOOST.Length > 0)
		{
			if(Tiles < AIMBOOST.Length)
			{
                ShotInfo.Value = AIMBOOST[Tiles];
            }            
            else //Use last value
            {
                ShotInfo.Value = AIMBOOST[AIMBOOST.Length - 1];
            }
            ShotInfo.ModType = eHit_Success;
            ShotInfo.Reason = FriendlyName;
            ShotModifiers.AddItem(ShotInfo);
		}
    }    
}

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local int Tiles;
    local ShotModifierInfo ShotInfo;

	if (Target.IsImpaired(false) || Target.IsBurning() || Target.IsPanicked())
		return;

	Tiles = Attacker.TileDistanceBetween(Target); 

	if(DEFENSEBOOST.Length > 0)
	{
		if(Tiles < DEFENSEBOOST.Length)
		{
            ShotInfo.Value = DEFENSEBOOST[Tiles];
        }            
        else //Use last value
        {
            ShotInfo.Value = DEFENSEBOOST[DEFENSEBOOST.Length - 1];
        }

		ShotInfo.ModType = eHit_Success;
		ShotInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ShotInfo);
	}

	if(DODGEBOOST.LENGTH > 0)
	{
		if(Tiles < DODGEBOOST.Length)
		{
            ShotInfo.Value = DODGEBOOST[Tiles];
        }            
        else //Use last value
        {
            ShotInfo.Value = DODGEBOOST[DODGEBOOST.Length - 1];
        }

		ShotInfo.ModType = eHit_Graze;
		ShotInfo.Reason = FriendlyName;
		ShotModifiers.AddItem(ShotInfo);
	}
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="LW2WotC_CloseandPersonal"
}