//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_Aggression
//  AUTHOR:  John Lumpkin (Pavonis Interactive), LWotC Team
//  PURPOSE: Sets up crit bonuses from Aggression perk
//--------------------------------------------------------------------------------------- 

class X2Effect_LW2WotC_Aggression extends X2Effect_Persistent config (LW_SoldierSkills);

var config int AGGRESSION_CONSISTENT_CRIT_BONUS;
var config int AGGRESSION_CRIT_BONUS_PER_ENEMY;
var config int AGGRESSION_MAX_CRIT_BONUS;
var config float AGGRESSION_DIMINISHING_RETURNS;
var config bool AGG_SQUADSIGHT_ENEMIES_APPLY;

var config int AGGRESSION_CONSISTENT_CRITDAMAGE_BONUS;
var config bool AGGRESSION_CRITDAMAGE_APPLIESTOEXPLOSIVE;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local XComGameState_Item	SourceWeapon;
    local ShotModifierInfo		ShotInfo;
	local int					BadGuys;
	local array<StateObjectReference> arrSSEnemies;
	local int				Bonus;
	local int				FinalBonus;
	local int				i;

    SourceWeapon = AbilityState.GetSourceWeapon();    
    if(SourceWeapon != none)	
	{
		BadGuys = Attacker.GetNumVisibleEnemyUnits (true, false, false, -1, false, false);
		if (Attacker.HasSquadsight() && default.AGG_SQUADSIGHT_ENEMIES_APPLY)
		{
			class'X2TacticalVisibilityHelpers'.static.GetAllSquadsightEnemiesForUnit(Attacker.ObjectID, arrSSEnemies, -1, false);
			BadGuys += arrSSEnemies.length;
		}
		if (BadGuys > 0)
		{
			FinalBonus = 0;

			for(i = 0; i < BadGuys; i++)
			{
				if(FinalBonus < default.AGGRESSION_MAX_CRIT_BONUS)
				{
					Bonus = default.AGGRESSION_CRIT_BONUS_PER_ENEMY - Round(default.AGGRESSION_DIMINISHING_RETURNS * i);
					FinalBonus += Clamp(Bonus, 0, default.AGGRESSION_MAX_CRIT_BONUS - FinalBonus);
				}
			}

			ShotInfo.ModType = eHit_Crit;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = FinalBonus + default.AGGRESSION_CONSISTENT_CRIT_BONUS;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
    local XComGameState_Item SourceWeapon;
    local XComGameState_Unit TargetUnit;
	local X2AbilityToHitCalc_StandardAim StandardHit;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;

    if(AppliedData.AbilityResultContext.HitResult == eHit_Crit)
    {
        SourceWeapon = AbilityState.GetSourceWeapon();
        if(SourceWeapon != none) 
        {
			if(	AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
			{
				return 0;
			}
			if (!default.AGGRESSION_CRITDAMAGE_APPLIESTOEXPLOSIVE)
			{
				if (X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate()).WeaponCat == 'grenade')
				{
					return 0;
				}
				if (AbilityState.GetMyTemplateName() == 'LW2WotC_RocketLauncher' || AbilityState.GetMyTemplateName() == 'LW2WotC_BlasterLauncher' || AbilityState.GetMyTemplateName() == 'MicroMissiles')
				{
					return 0;
				}
				StandardHit = X2AbilityToHitCalc_StandardAim(AbilityState.GetMyTemplate().AbilityToHitCalc);
				if(StandardHit != none && StandardHit.bIndirectFire) 
				{
					return 0;
				}
			}
			WeaponDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
			if (WeaponDamageEffect != none)
			{
				if (WeaponDamageEffect.bIgnoreBaseDamage)
				{
					return 0;
				}
			}
			TargetUnit = XComGameState_Unit(TargetDamageable);
            if(TargetUnit != none)
            {

				return default.AGGRESSION_CONSISTENT_CRITDAMAGE_BONUS;
            }
        }
    }
    return 0;
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="LW2WotC_Aggression"
}
