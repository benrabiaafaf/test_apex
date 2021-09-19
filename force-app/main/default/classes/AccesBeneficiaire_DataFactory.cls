public with sharing class AccesBeneficiaire_DataFactory {
	
    public static Acces_beneficiaire__c createBeneficiaire(String name, ID compteId, String email, String statut, Boolean doInsert) {

        Acces_beneficiaire__c result = new Acces_beneficiaire__c(
            Name = name,  
            AccessAccount__c = compteId,
            AccessEmail__c = email, 
            AccessStoreState__c = statut
        );
        if( doInsert ){
            INSERT result;
        }                                                     
        return result;
    }
}