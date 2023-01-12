public class DiscountForOppHandler {
    public void beforeInsertDiscount(List<Opportunity> newOpportunityList){
        
        List <Opp_discount__mdt> mdtValue = [SELECT Amount_of_Discount__c, Duration__c FROM Opp_discount__mdt];
        Map <Id,Account> accMap = new Map<Id,Account> ([SELECT ID,Registration_Date__c FROM Account ]);
        
        
        for(Opportunity opp : newOpportunityList){
            
            Account acc = accMap.get(opp.AccountId);
            
            if(opp.Amount!=null && acc!=null && acc.Registration_Date__c!=null){
                
                Integer datesbetween = acc.Registration_Date__c.daysBetween(Date.today());
                
                Decimal currentDuration = 0; // temp value for saving amount of days
                Decimal currentDiscount = 0;
                
                for(Opp_discount__mdt oneMdt : mdtValue ){
                    // checks if amount of days between date of registration and today is bigger than value in Mdt
                    // and checks currentDuration to prevent reducing value
                    if(datesbetween - (oneMdt.Duration__c*365) > 0 && currentDuration < oneMdt.Duration__c){
                        currentDuration = oneMdt.Duration__c;
                        currentDiscount = oneMdt.Amount_of_Discount__c;
                    }
                }
                
                if(currentDiscount>0){
                    opp.Amount = opp.Amount * (1 - currentDiscount / 100);
                } 
            }
        }  
    }
    
    public void beforeInsertGift(List<Opportunity> newOpportunityList){
        
        List<id> idOfRelativeGiftCards = new List<id>();
        
        for(Opportunity opp:newOpportunityList ){
            idOfRelativeGiftCards.add(opp.Gift_Card_field__c);
        }
        
        List <Gift_Card__c> giftList = [SELECT id,	Amount__c, Active__c FROM Gift_Card__c WHERE id IN :idOfRelativeGiftCards];
        List <Gift_Card__c> giftListToUpdate = new List <Gift_Card__c>();
        error_message__mdt errorText = [SELECT errorText__c FROM error_message__mdt LIMIT 1];
        
        
        for(Gift_Card__c card : giftList){
            for(Opportunity opp2 : newOpportunityList){
                if(card.id == opp2.Gift_Card_field__c){
                    Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp2.id);               
                    if(card.Active__c){
                        opp2.Amount -=card.Amount__c;
                        card.Active__c = false;
                        giftListToUpdate.add(card);
                    }
                    else if(!card.Active__c && opp2.Gift_Card_field__c != oldOpp.Gift_Card_field__c){
                        opp2.Gift_Card_field__c.addError(errorText.errorText__c);
                    }
                }
            }
        }  
        if(giftListToUpdate!= null){
            update giftListToUpdate;    
        }
        
    }
}