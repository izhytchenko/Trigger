@isTest
public class DiscountForOppHandlerTest{
   	static final Integer AMOUNT_OF_OPPORTUNITIS = 10000;
    static final Integer DISCOUNT = 700;
    static final Integer FINAL_AMOUNT = AMOUNT_OF_OPPORTUNITIS - DISCOUNT;
    
    @testSetup 
    static void setup() {
        Date dateOfRegistration =  Date.newInstance(2017, 05, 20);
        Account accToInsert = new Account (Name = 'testTriger', Registration_Date__c = dateOfRegistration); 
        insert accToInsert;
        Opportunity oppForTestGiftCard = new Opportunity (Name = 'testOpp', StageName = 'Qualification', 	
                                                          CloseDate = Date.newInstance(2022, 01, 01), Amount = AMOUNT_OF_OPPORTUNITIS);
        insert oppForTestGiftCard;
        Gift_Card__c cardTestGiftCard = new Gift_Card__c (Amount__c = DISCOUNT, Active__c = true); 
        insert cardTestGiftCard;  
    }
    
    @isTest
    public static void oneOppTest(){
       
        Account accToInsert = [SELECT id FROM Account WHERE Name = 'testTriger'];
       	Opportunity oppToInsert = new Opportunity(AccountId =accToInsert.Id, CloseDate = Date.newInstance(2022, 01, 01),
                                                  StageName = 'Qualification', 	Name = 'forUnitTest' , 	Amount = AMOUNT_OF_OPPORTUNITIS);
        Test.startTest();
        Database.SaveResult result = Database.insert(oppToInsert,false);
        Test.stopTest();
        
        Id idOfOpp = result.getId();
        Opportunity oppAfterInsert = [SELECT Amount FROM Opportunity WHERE Id = : idOfOpp];
        System.assertEquals(FINAL_AMOUNT ,oppAfterInsert.Amount,'Amount in oneOppTest should be 9300, real is ' + oppAfterInsert.Amount);
    }
    
    @isTest
    public static void bulkOppTest(){
        Account accToInsert = [SELECT id FROM Account WHERE Name = 'testTriger'];  
        Opportunity oppToInsert = new Opportunity(AccountId =accToInsert.Id, CloseDate = Date.newInstance(2022, 01, 01),
                                                  StageName = 'Qualification', 	Name = 'forUnitTest' , 	Amount = AMOUNT_OF_OPPORTUNITIS);
        List<Opportunity> listoppToInsert = new List<Opportunity>();
        
        for(Integer i = 0; i <50; i++){
           listoppToInsert.add(new Opportunity(AccountId =accToInsert.Id, CloseDate = Date.newInstance(2022, 01, 01),
                                                  StageName = 'Qualification', 	Name = 'forUnitTest'+i , Amount = AMOUNT_OF_OPPORTUNITIS));
        }
        
        Test.startTest();
        Database.SaveResult[] result = Database.insert(listoppToInsert,false);
        Test.stopTest();
        
        for(Database.SaveResult sr : result){
            Id idOfOpp = sr.getId();
			Opportunity oppAfterInsert = [SELECT Amount FROM Opportunity WHERE Id = : idOfOpp];
			System.assertEquals( FINAL_AMOUNT ,oppAfterInsert.amount,'Amount in bulkOppTest should be 9300, real is ' + oppAfterInsert.Amount);            
        }           
    }

	@isTest
    public static void GiftTest(){ 
        Opportunity oppForTestGiftCard = [SELECT Name, Id, Gift_Card_field__c, Amount FROM Opportunity WHERE Name = 'testOpp'];
        Gift_Card__c gift = [SELECT Id FROM Gift_Card__c WHERE Amount__c =: DISCOUNT LIMIT 1];
        oppForTestGiftCard.Gift_Card_field__c = gift.Id;
        Test.startTest();
        Database.SaveResult result = Database.update(oppForTestGiftCard,false);
        Test.stopTest();
        
        Id idOfOpp = result.getId();
        Opportunity oppAfterUpdate = [SELECT Amount FROM Opportunity WHERE Id =: idOfOpp];
        System.assertEquals(FINAL_AMOUNT , oppAfterUpdate.Amount, 'Amount in GiftTest should be 9300, real is ' + oppAfterUpdate.Amount);
    }
}