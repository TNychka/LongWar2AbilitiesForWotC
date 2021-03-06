///---------------------------------------------------------------------------------------
//  FILE:    X2Effect_LW2WotC_Trojan
//  AUTHOR:  Amineri (Pavonis Interactive)
//  PURPOSE: Implements effect for Trojan ability -- this is a triggering effect that occurs
//--------------------------------------------------------------------------------------- 
//---------------------------------------------------------------------------------------
class X2Effect_LW2WotC_Trojan extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'XpSuccessfulHack', OnSuccessfulHack, ELD_OnStateSubmitted, 75,, true, EffectObj);
}

//This is triggered by a successful hack (on InteractiveObject or Unit)
//Because it can trigger for hacking doors/chests, we have to check that it applied to a unit
static function EventListenerReturn OnSuccessfulHack(Object EventData, Object EventSource, XComGameState GameState, Name InEventID, Object CallbackData)
{
    local XComGameState_Unit SourceUnit, TargetUnit;
    local XpEventData XpEvent;
    local XComGameStateHistory History;
    local XComGameState_Effect EffectGameState;

    //`LOG("PerkPack(Trojan): Event XpSuccessfulHack Triggered");
    History = `XCOMHISTORY;
    XpEvent = XpEventData(EventData);
    if(XpEvent == none)
    {
        `REDSCREEN("PerkPack(Trojan): XpSuccessfulHack Event with invalid event data.");
        return ELR_NoInterrupt;
    }

    //`LOG("PerkPack(Trojan): Valid event data");
    EffectGameState = XComGameState_Effect(CallbackData);
    if(EffectGameState == none)
        return ELR_NoInterrupt;
        
    //`LOG("PerkPack(Trojan): Retrieving Source Unit");
    SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(XpEvent.XpEarner.ObjectID));
    if(SourceUnit == none || SourceUnit != XComGameState_Unit(History.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID)))
        return ELR_NoInterrupt;

    //`LOG("PerkPack(TrojanVirus): Retrieving Target Unit");
    TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(XpEvent.EventTarget.ObjectID));
    if(TargetUnit == none)
        return ELR_NoInterrupt;

    // Don't apply trojan to fully-overridden robots. The MC effect is permanent anyway, so we don't need to apply this.
    // Applying it means the flyover will appear on EVAC, which we don't want.
    if (TargetUnit.AffectedByEffectNames.Find('TransferMecToOutpost') != -1)
    {
        //`LOG("Skipping trojan on full override target");
        return ELR_NoInterrupt;
    }

    //`LOG("PerkPack(Trojan): Activating TrojanVirus on Target Unit.");
    ActivateAbility('LW2WotC_TrojanVirus', SourceUnit.GetReference(), TargetUnit.GetReference());
    return ELR_NoInterrupt;
}

//This is used to activate the secondary TrojanVirus ability, which applies the TrojanVirus effect to the target of a successful hack
static function ActivateAbility(name AbilityName, StateObjectReference SourceRef, StateObjectReference TargetRef)
{
    local GameRulesCache_Unit UnitCache;
    local int i, j;
    local X2TacticalGameRuleset TacticalRules;
    local StateObjectReference AbilityRef;
    local XComGameState_Unit SourceState; //, TargetState;
    local XComGameStateHistory History;
    History = `XCOMHISTORY;
    SourceState = XComGameState_Unit(History.GetGameStateForObjectID(SourceRef.ObjectID));
    AbilityRef = SourceState.FindAbility(AbilityName);

    TacticalRules = `TACTICALRULES;
    if( AbilityRef.ObjectID > 0 &&  TacticalRules.GetGameRulesCache_Unit(SourceRef, UnitCache) )
    {
        //`LOG("PerkPack(TrojanVirus): Valid ability, retrieved UnitCache.");
        for( i = 0; i < UnitCache.AvailableActions.Length; ++i )
        {
            if( UnitCache.AvailableActions[i].AbilityObjectRef.ObjectID == AbilityRef.ObjectID )
            {
                //`LOG("PerkPack(TrojanVirus): Found matching Ability ObjectID=" $ AbilityRef.ObjectID);
                for( j = 0; j < UnitCache.AvailableActions[i].AvailableTargets.Length; ++j )
                {
                    if( UnitCache.AvailableActions[i].AvailableTargets[j].PrimaryTarget == TargetRef )
                    {
                        //`LOG("PerkPack(TrojanVirus): Found Target ObjectID=" $ TargetRef.ObjectID);
                        if( UnitCache.AvailableActions[i].AvailableCode == 'AA_Success' )
                        {
                            //`LOG("PerkPack(TrojanVirus): AvailableCode AA_Success");
                            class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[i], j);
                        }
                        else
                        {
                            //`LOG("PerkPack(TrojanVirus): AvailableCode = " $ UnitCache.AvailableActions[i].AvailableCode);
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
    EffectName="Trojan";
}