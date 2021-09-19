@isTest
private class SubscriptionComplianceCheckTest {
    private static final Integer ITERATION = 200;
    private static final String BOUTIQUE = 'Conformité Boutique';
    private static final String CREDIT = 'Conformité Crédits';
    private static final String PARENT_BUNDLE = 'Conformité Parent Bundle';
    private static final String DIFFUSION_LBC = 'Conformité Diffusion LBC';
    private static final String DIFFUSION_AVAL = 'Conformité Diffusion AVAL';
    private static final String VISIBILITE_AVAL = 'Conformité Visibilité AVAL';
    private static final String PUB_LOCAL = 'Conformité Pub Local';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String CONFORME = 'Conforme';
    private static final String CREATED = 'Created';
    private static final String MODE = 'Fashion';
    private static final String SSII = 'JobServiceCompany';
    private static final String MME = 'Ms';
    private static final String CLOVER = 'CLOVER';
    private static final String MANUEL = 'Manuel';
    private static final String UBIFLOW = 'Ubiflow';
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String PRODUCT_WORKFLOW = 'yeah';

    @testSetup 
    static void setup() {
        // CREATE ACCOUNT WITH MONDATORY AND MINIMUM REQUIERED FIELDS AND INSERT IT
        Account_DataFactory.createAccount('compte_1', '+33 6 00 00 00 00','37915832200097',true);
        // CREATE Acces_beneficiaire__c WITH MONDATORY AND MINIMUM REQUIERED FIELDS AND INSERT IT WITH MINIMUM REQUIERED FIELDS AND INSERT IT
        AccesBeneficiaire_DataFactory.createBeneficiaire('benef_1',compte.Id,'test1@lbc.fr',CREATED,true); 
    }

    @isTest
    private static void testConformite() {
        Account compte = [ SELECT Id FROM  Account LIMIT 1];
        Acces_beneficiaire__c benef = [ SELECT Id FROM  Acces_beneficiaire__c LIMIT 1] ;
        
        // CREATE PARENT SUBSCRIPTION
        SBQQ__Subscription__c parent = new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = PARENT_BUNDLE
        );
        INSERT parent;

        // CREATE CHILD SUBSCRIPTIONS WITH ALL REQUIRED FIELDS AND INSERT THEM
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        for(Integer i = 1; i < ITERATION; i++) {
            subs.add(new SBQQ__Subscription__c(
                SBQQ__Quantity__c = 5,
                Status__c = ELEMENTS_MANQUANTS,
                ComplianceProcess__c = IMMO_NEUF,
                PromoterDescription__c = 'TEST DESCRIPTION', 
                FlowType__c = MANUEL, 
                ProductWorkflow__c = PRODUCT_WORKFLOW,
                ContractEmail__c = 'testemail@test.com', 
                CompanySiret__c = 'SIRET', 
                CompanyName__c = 'TEST COMPANY',
                CompanyAddressStreet__c = 'TEST STREET', 
                CompanyAddressZipcode__c = '77777', 
                CompanyAddressCity__c = 'TEST CITY',
                CompanyPhone__c = '+33 6 00 00 00 66', 
                ContactGender__c = 'Male', 
                ContactFirstName__c = 'TEST', 
                ContactLastName__c = 'TEST', 
                LeadPhone__c ='+33 6 00 00 00 66',
                SBQQ__RequiredById__c = parent.Id
            ));
        }
        INSERT subs;
        
        System.assertEquals(ITERATION,[SELECT Id FROM SBQQ__Subscription__c].size());

        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        System.assertEquals(ITERATION,[SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true].size());
    }

    @isTest
    private static void testNoConformite(){
        Account compte = [ SELECT Id FROM  Account LIMIT 1];
        Acces_beneficiaire__c benef = [ SELECT Id FROM  Acces_beneficiaire__c LIMIT 1] ;

        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();

        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = IMMO_NEUF,
            LeadPhone__c = '+33 6 00 00 00 66',
			ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            FlowType__c = MANUEL,
            PromoterDescription__c = 'UBIFLOW4'
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = BOUTIQUE,
            ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            FlowType__c = MANUEL,
            BeneficiaryAccount__c = compte.Id
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = DIFFUSION_LBC,
            ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            BeneficiaryAccount__c = compte.Id,
            BroadcastSoftware__c = CLOVER,
            BroadcastPartner__c = UBIFLOW,
            FlowType__c = MANUEL
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = DIFFUSION_AVAL,
            FlowType__c = MANUEL,
            ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            BeneficiaryAccount__c = compte.Id
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = VISIBILITE_AVAL,
            FlowType__c = MANUEL,
            ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            SBQQ__RequiredById__c = parent.Id,
            BeneficiaryAccount__c = compte.Id
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = CREDIT,
            FlowType__c = MANUEL,
            ProductWorkflow__c = PRODUCT_WORKFLOW,
            BeneficiaryAccess__c = benef.Id,
            BeneficiaryAccount__c = compte.Id
        ));
        subs.add(new SBQQ__Subscription__c(
            SBQQ__Quantity__c = 5,
            Status__c = ELEMENTS_MANQUANTS,
            ComplianceProcess__c = PUB_LOCAL,
            OrderNumber__c = '00215',
            PostalCode__c = 7500,
            KilometerRadius__c = '50',
            PrintVolume__c = 25
        ));

        INSERT subs;

        System.assertEquals(subs.size(),[SELECT Id FROM SBQQ__Subscription__c].size());

        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        System.assertEquals(0,[SELECT Id FROM SBQQ__Subscription__c WHERE Souscription_Conforme__c = true].size());
    }
}