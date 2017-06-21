trigger LineItemTrigger on Line_Item__c (before update) {
/*
  Map<string,Decimal> mapBookNames = new Map<string,Decimal>();
  set<id> setProductIds = new Set<id>();
  set<id> setAcctIds = new Set<id>();
  Map<id,String> mapProducts = new Map<id,String>();
  id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Warehouse').getRecordTypeId();  
    
  for(Line_Item__c eachLI : [select id,Book__r.Name,Book__c,Quantity__c from Line_Item__c where id in: Trigger.new]){
         mapBookNames.put(eachLI.Book__r.Name,eachLI.Quantity__c);
         setProductIds.add(eachLI.Book__c);
  }

 
   for( Product2 eachPrd : [SELECT id,Account__c,Account__r.Name FROM Product2 where 
                            Name in: mapBookNames.keyset() 
                            and Family = 'Inventory']){
        setAcctIds.add(eachPrd.Account__c);
        System.debug('Account Name from Porduct Object --'+eachPrd.Account__r.Name);
    } 
 
/// one way    
list<Product2> prdUpdate = new list<Product2>();
   for(Account eachAcct: [select id, name,RecordTypeid, (Select id,Name,Family,Inventory__c from products__r where name in: mapBookNames.keyset()) 
                                                            from Account where id in: setAcctIds and RecordTypeId =: rtId order by Name asc]){
       List<Product2> collectnames = new List<Product2>();

            for(Product2 eachprd: eachAcct.products__r){ 
                if(mapBookNames.get(eachPRD.Name) != Null){
                    eachPrd.Inventory__c = eachPrd.Inventory__c - mapBookNames.get(eachPRD.Name);
                    if(eachPrd.Inventory__c >0){ 
                        collectnames.add(eachPrd);
                    }
                }                       
            }                                                                    
            if(eachAcct.products__r.Size() == collectnames.size()){
               prdUpdate.addAll(collectnames); break;
            }   
            
    }
    
    sYSTEM.debug('TEST LOG 1--' +PrdUpdate);
 // alternate way 
    
    */
    
}