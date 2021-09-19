public static with sharing class TH01_SubscriptionTrigger{

    public static void updateContractEndDate(List<SBQQ__Subscription__c> newSubs){

        Boolean isTerminate;
        Date terminatedDate;
        Date endDate;
    
        Set<Id> contractsIds = new Set<Id>();
        List<Contract> contractsToUpdate = new List<Contract>(); 
        
        try {
            for (SBQQ__Subscription__c vSub :newSubs) {
                contractsIds.add(vSub.SBQQ__Contract__c);    // SUPPOSING THAT EACH SUBSCRIPTION IS NECESSARLY ATTACHED TO A CONTRACT
            }
            List<Contract> contractsWithSubscriptions =  [
                SELECT 
                    Id, 
                    EndDate, 
                    (   SELECT 
                            Id, 
                            SBQQ__EndDate__c, 
                            SBQQ__TerminatedDate__c, 
                        FROM 
                            SBQQ__Subscriptions__r
                    ) 
                FROM 
                    Contract 
                WHERE 
                    Id IN :contractsIds
            ];
            for (Contract vContract :  contractsWithSubscriptions) {
                system.debug('#TH01_SubscriptionTrigger.updateContractEndDate contrat = '+vContract); 
                isTerminate = true;
                terminatedDate = vContract.EndDate;
                endDate = vContract.EndDate;
                
                // A CONTRACT IS TERMINATE IF ALL SUBSCRITION HAVE TERMINATED DATE, IN THIS CASE : TAKE THE FARTHEST TERMINATE DATE
                // IF AT LEAST ONE OF THE SUBSCRIPTIONS ON CURRENT CONTRACT HAS NO TERMINATE DATE, SET CONTRACT END DATE TO THE FARTHEST END DATE
                for (SBQQ__Subscription__c vSub : vContract.SBQQ__Subscriptions__r) {
                    // AS SOON AS A SUBSCRIPTION IS NOT TERMINATED, MARK CONTRAT AS NOT TERMINATED
                    if (vSub.SBQQ__TerminatedDate__c == null && isTerminate ) {
                        isTerminate = false;
                    }
                    // UPDATE TERMINATED DATE ONLY IF CONTRACT IS STILL TERMINATED
                    if (isTerminate && terminatedDate < vSub.SBQQ__TerminatedDate__c) {
                        terminatedDate = vSub.SBQQ__TerminatedDate__c;
                    }
                    if (vSub.SBQQ__EndDate__c != null && endDate < vSub.SBQQ__EndDate__c) {
                        endDate = vSub.SBQQ__EndDate__c;
                    }
                }
                
                vContract.EndDate = isTerminate ? terminatedDate : endDate;
                system.debug('#TH01_SubscriptionTrigger.updateContractEndDate EndDate = '+ vContract.EndDate);                                                   
                contractsToUpdate.add(vContract);
            }
            
            UPDATE contractsToUpdate;
            
        } catch(Exception e) {
            Logs.error('TH01_SubscriptionTrigger.updateContractEndDate','SBQQ__Subscription__c Trigger insert & update', e);
        }
    }
}