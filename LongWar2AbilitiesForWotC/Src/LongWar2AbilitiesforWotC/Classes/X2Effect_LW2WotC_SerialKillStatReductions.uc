///---------------------------------------------------------------------------------------
//  FILE:    X2Effect_SerialKillStatReductions
//  AUTHOR:  Favid, LWotC Team
//  PURPOSE: Implements static and stacking penalties for Serial and Death from Above
//--------------------------------------------------------------------------------------- 
//---------------------------------------------------------------------------------------

class X2Effect_LW2WotC_SerialKillStatReductions extends X2Effect_Persistent;

var int CritReductionPerKill;
var int AdditionalCritReduction;
var int AimReductionPerKill;
var int AdditionalAimReduction;
var int DamageFalloffPerKill;
var int AdditionalDamageFalloff;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local ShotModifierInfo ModInfo;
    local XComGameState_Item SourceWeapon;
    local UnitValue UnitVal;
	local int CritReduction, AimReduction;

	Attacker.GetUnitValue ('SerialKills', UnitVal);
	CritReduction = CritReductionPerKill * UnitVal.fValue + AdditionalCritReduction;
	AimReduction = AimReductionPerKill * UnitVal.fValue + AdditionalAimReduction;

    SourceWeapon = AbilityState.GetSourceWeapon();
    if(SourceWeapon != none)
    {
        ModInfo.ModType = eHit_Crit;
        ModInfo.Reason = FriendlyName;
        ModInfo.Value = -CritReduction;
        ShotModifiers.AddItem(ModInfo);

		ModInfo.ModType = eHit_Success;
        ModInfo.Reason = FriendlyName;
        ModInfo.Value = -AimReduction;
        ShotModifiers.AddItem(ModInfo);
    }
}


function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local UnitValue UnitVal;
    
	Attacker.GetUnitValue ('SerialKills', UnitVal);

	return -(DamageFalloffPerKill * UnitVal.fValue + AdditionalDamageFalloff * (UnitVal.fValue - 1));

	return 0;
}