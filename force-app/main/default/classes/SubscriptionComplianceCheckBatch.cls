global class SubscriptionComplianceCheck_Batch implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String PUB = 'Conformité Pub';
    private static final String IMMO_NEUF_MISSING_INFO ='CERTAINS CHAMPS SONT MANQUANTS';
    private static final String IMMO_NEUF_MISSING_INFO ='CERTAINS CHAMPS SONT MANQUANTS';
    private static final String PUB_MISSING_INFO ='LA DATE DE FIN EFFECTIVE EST PASSEE';
    private static final List<String> COMPLIENCE_PROCESSES = new List<String>{IMMO_NEUF, PUB};

    
    global List<SBQQ__Subscription__c> start(Database.BatchableContext cnx) { 
        // Keep only used fields
        return [SELECT 
                    Id, 
                    CompanyAddressCity__c, 
                    //OrderNumber__c,           // Unused field
                    //CompanyAddressCountry__c, // Unused field
                    CompanyPhone__c, 
                    ContactGender__c, 
                    ContactLastName__c, 
                    ContactFirstName__c, 
                    //Companyindustry__c,       // Unused field 
                    CompanyName__c, 
                    //PrintVolume__c,           // Unused field
                    //BroadcastSoftware__c,     // Unused field
                    PromoterDescription__c, 
                    SBQQ__RequiredById__c,
                    SBQQ__RequiredById__r.Souscription_Conforme__c, // Query parent subscription conformity
                    FlowType__c, 
                    //BroadcastPartner__c,      // Unused field
                    //PostalCode__c,            // Unused field
                    Souscription_Conforme__c, 
                    ComplianceProcess__c, 
                    Status__c, 
                    //AccessStoreState__c,      // Unused field
                    ProductWorkflow__c, 
                    //AccessUserId__c,          // Unused field
                    //KilometerRadius__c,       // Unused field
                    //AccessStoreId__c,         // Unused field
                    CompanyAddressStreet__c, 
                    CompanyAddressZipcode__c, 
                    LeadPhone__c,
                    ContractEmail__c, 
                    //CompanySegment__c,        // Unused field then in execute method
                    CompanySiret__c,
                    EffectiveEndDate__c,
                    MissingInformations__c
                FROM 
                    SBQQ__Subscription__c 
                WHERE 
                    Status__c = :ELEMENTS_MANQUANTS
                AND ComplianceProcess__c IN :COMPLIENCE_PROCESSES 
                AND Souscription_Conforme__c = false
            ];
    }
    
    global void execute(Database.BatchableContext cnx, List<SBQQ__Subscription__c> scope) { // scope cn contain parent and child subscriptions
        try {
            Map<Id,SBQQ__Subscription__c> subsToUpdate = new Map<Id,SBQQ__Subscription__c>();   // use map to check if parent has not been already updated 
            for(SBQQ__Subscription__c vSub : scope) {
                SBQQ__Subscription__c checkedSub = setConformite(vSub);
                if (checkedSub != null) {
                    subsToUpdate.put(checkedSub.Id,checkedSub);   // add subscription to be updated
                    // update parent subscription
                    if (    vSub.SBQQ__RequiredById__c != null 
                        &&  vSub.SBQQ__RequiredById__r.Souscription_Conforme__c != true
                        &&  !subsToUpdate.containsKey(vSub.SBQQ__RequiredById__c)
                    ){
                        subsToUpdate.put(
                            vSub.SBQQ__RequiredById__c, 
                            new SBQQ__Subscription__c(
                                Id = vSub.SBQQ__RequiredById__c,
                                Souscription_Conforme__c = true
                            )
                        );
                    }
                }else{
                    subsToUpdate.put(vSub.Id,setMissingInformation(vSub));
                }
            }
            UPDATE subsToUpdate.values();
        } catch(Exception e) {
            Logs.error('SubscriptionComplianceCheck','Batch Compliance Check', e);
        }
    }
    
    global void finish(Database.BatchableContext cnx) {
    }
    
    private Boolean isConforme(SBQQ__Subscription__c sub){
        if(sub.ComplianceProcess__c == IMMO_NEUF){
            return(
                    sub.PromoterDescription__c != null 
                &&  sub.FlowType__c != null 
                &&  sub.ProductWorkflow__c != null
                &&  sub.ContractEmail__c != null 
                &&  sub.CompanySiret__c != null 
                &&  sub.CompanyName__c != null
                &&  sub.CompanyAddressStreet__c != null 
                &&  sub.CompanyAddressZipcode__c != null 
                &&  sub.CompanyAddressCity__c != null
                &&  sub.CompanyPhone__c != null 
                &&  sub.ContactGender__c != null 
                &&  sub.ContactFirstName__c != null 
                &&  sub.ContactLastName__c != null 
                &&  sub.LeadPhone__c != null
            );
        }else if(sub.ComplianceProcess__c == PUB){
            return (sub.EffectiveEndDate__c > Date.today());
        }
        return false;
    }


    private SBQQ__Subscription__c setConformite(SBQQ__Subscription__c sub) {
        if(isConforme(sub)) {
            sub.Souscription_Conforme__c = true;
            return sub;
        }
        return null;
    }

    private SBQQ__Subscription__c setMissingInformation(SBQQ__Subscription__c sub) {
        if(sub.ComplianceProcess__c == IMMO_NEUF){
            sub.MissingInformations__c = IMMO_NEUF_MISSING_INFO;
            return sub;
        }else if(sub.ComplianceProcess__c == PUB){
            sub.MissingInformations__c = PUB_MISSING_INFO;
            return sub;
        }
        return null;
    }
}