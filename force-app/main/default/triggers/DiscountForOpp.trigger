trigger DiscountForOpp on Opportunity (before insert, before update ,after update,after insert) {
    DiscountForOppHandler tgHandler = new DiscountForOppHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            tgHandler.beforeInsertDiscount(Trigger.New);
            tgHandler.beforeInsertGift(Trigger.New);
        }
        else if(Trigger.isUpdate){
             tgHandler.beforeInsertGift(Trigger.New);
        }
    }
    else if(Trigger.isAfter){
        if(Trigger.isUpdate){     
            
        }
    }
  
}