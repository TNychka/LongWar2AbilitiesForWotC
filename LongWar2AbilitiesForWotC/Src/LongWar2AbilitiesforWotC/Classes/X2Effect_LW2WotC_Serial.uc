///---------------------------------------------------------------------------------------
//  FILE:    X2Effect_LW2WotC_Serial
//  AUTHOR:  LWotC Team
//  PURPOSE: Modified version of vanilla Serial that can be limited in the amount of bonus shots it grants
//--------------------------------------------------------------------------------------- 
//---------------------------------------------------------------------------------------
class X2Effect_LW2WotC_Serial extends X2Effect_Persistent config(LW_SoldierSkills);

var config int SERIAL_USES_PER_TURN;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'SerialKiller', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Unit TargetUnit;
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local UnitValue	SerialUsesThisTurn;
	local int iUsesThisTurn;

	SourceUnit.GetUnitValue ('LW2WotC_SerialUses', SerialUsesThisTurn);
	iUsesThisTurn = int(SerialUsesThisTurn.fValue);
	if (iUsesThisTurn >= default.SERIAL_USES_PER_TURN)
    {
        return false;
    }

	//  match the weapon associated with Serial to the attacking weapon
	if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		//  check for a direct kill shot
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != none && TargetUnit.IsDead())
		{
			//  restore the pre cost action points to fully refund this action
			if (SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
			{
				AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
				if (AbilityState != none)
				{
					SourceUnit.SetUnitFloatValue ('LW2WotC_SerialUses', iUsesThisTurn + 1.0, eCleanup_BeginTurn);
					SourceUnit.ActionPoints = PreCostActionPoints;

					EventMgr = `XEVENTMGR;
					EventMgr.TriggerEvent('SerialKiller', AbilityState, SourceUnit, NewGameState);

					return true;
				}
			}
		}
	}
	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	EffectName = "SerialKiller"
}