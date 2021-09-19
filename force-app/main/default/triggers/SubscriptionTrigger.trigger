trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert, after update) {
    if( Trigger.isAfter && Trigger.isInsert){
        TH01_SubscriptionTrigger.updateContractEndDate(Trigger.new);
    }
    if( Trigger.isAfter && Trigger.isUpdate){
        // ON WHICH FIELDS UPDATE ??
        TH01_SubscriptionTrigger.updateContractEndDate(Trigger.new);
    }
}