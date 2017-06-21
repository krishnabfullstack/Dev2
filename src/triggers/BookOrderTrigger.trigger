/*==============================================
* Apex Class Name : BookList
* Version             : 1.0 
* Created Date        : 23 February 2017
* Function            : Trigger
* Modification Log 
* Developer                   Date                    Description
* -----------------------------------------------------------------------------------------------------------
* Krishna Bogavelli           02/23/2016            Final version
-------------------------------------------------------------------------------------------------------------
=================================================*/
trigger BookOrderTrigger on Book_Order__c (before Update) {

  if(Trigger.isUpdate){ 
    //Collecting Book Order Ids
     set<Id> setBookOrderId = new set<Id>();

    // Collecting book order ids  
    for (Book_Order__c eachBO : Trigger.new){ system.debug('eachBO***'+eachBO);
        if (eachBO.Order_Status__c == 'Ordered')
        setBookOrderId.add(eachBO.Id);
    }
    system.debug('setBookOrderId***'+setBookOrderId);
    /*======================Ccollecting list of line items================================*/
    List<Line_Item__c> lstBOLineItem = new List<Line_Item__c>();   
    Map<String,String> mapBOLineItem = new Map<String,String>();
    Map<String,decimal> mapBookQuan = new Map<String,decimal>();
    set<Id> setCollectionID = new Set<Id>();

    lstBOLineItem = [SELECT id,name,Quantity__c,Book_Order__c,Book_Order__r.Name,Book__r.Family,Book__r.Collection__c,Book__c 
                        FROM Line_Item__c 
                       WHERE Book_Order__c IN : setBookOrderId ];   

    for (Line_Item__c li:lstBOLineItem ){
        mapBOLineItem.put(li.name,li.name);
        mapBookQuan.put(li.name,li.Quantity__c);
        setCollectionID.add(li.Book__c); 
    }

    system.debug('mapBOLineItem***'+mapBOLineItem.size());
    /*======================Collecting list of books related to Collection================================*/
    
    List<product2> lstCollectionBook = new List<product2>();

    lstCollectionBook = [SELECT Id,Name,Account__c,Collection__r.name 
                            FROM Product2 
                           WHERE Account__r.Type = 'Book Seller' AND Collection__c IN : setCollectionID ];

    for (product2 prd: lstCollectionBook){ 
        mapBOLineItem.put(prd.name,prd.name);
        mapBookQuan.put(prd.name,mapBookQuan.get(prd.Collection__r.name)); 
        mapBOLineItem.remove(prd.Collection__r.name);
    }

   /*======================Collecting books related to warehouse accounts AND Collecting related warehouse account ids================================*/
    List<product2> lstBooks = new List<product2>();
    set<Id> setAccountId  = new set<Id>();
    Map<Id,Integer> mapCount = new Map<Id,Integer>();

    lstBooks = [SELECT Id,Name,Account__c FROM Product2 
                                         WHERE Account__r.Type = 'Warehouse' 
                                           AND Name IN : mapBOLineItem.KeySet()];
    
    system.debug('lstBooks***'+lstBooks);

    for (product2 bl: lstBooks ){
        setAccountId.add(bl.Account__c);
    }

   /*======================mapping account ids to size of related books================================*/
    for (AggregateResult ar : [SELECT count(Id)cnt ,Account__c 
                                 FROM Product2 
                                WHERE Account__c  IN : setAccountId AND Name IN : mapBOLineItem.KeySet() GROUP BY Account__c ]){
        mapCount.put((Id)ar.get('Account__c'),(Integer)ar.get('cnt'));
    }
    system.debug('mapCount***'+mapCount);

    set<Id> ReqAccId = new set<Id>() ;
    for (product2 p2 : lstBooks){
        if ((lstBOLineItem.size() == mapCount.get(p2.Account__c)) || mapBOLineItem.get(p2.Name).CONTAINS(p2.Name))
          ReqAccId.add(p2.Account__c);
        break;
    }
    system.debug('ReqAccId***'+ReqAccId);

    List<Product2> lstFinalPrdUpdate = new List<Product2>();
    Map<string,string> mapBOPrd = new Map<String,string>();
    Map<string,string> mapNOBOPrd = new Map<String,string>();
    decimal FinalBookcount;

    for (Product2 finalprod : [SELECT Id,Name,Account__c,Inventory__c 
                                 FROM Product2 
                                WHERE Account__c IN : ReqAccId AND Name IN : mapBOLineItem.KeySet()]){
        if (finalprod.Inventory__c != 0){ 
            finalprod.Inventory__c = finalprod.Inventory__c - mapBookQuan.get(finalprod.Name);
            FinalBookcount = finalprod.Inventory__c; 
        }else if(finalprod.Inventory__c == 0){
                mapNOBOPrd.put(finalprod.Name,finalprod.Name);
              }   
        if (FinalBookcount >= 0) {        
            lstFinalPrdUpdate.add(finalprod);
            mapBOPrd.put(finalprod.Name,finalprod.Name);
        }  
    }
    system.debug('FinalBookcount***'+FinalBookcount);
    system.debug('lstFinalPrdUpdate***'+lstFinalPrdUpdate);


    /*======================UPDATE Books inventory================================*/  
    if (lstFinalPrdUpdate.size()> 0 )
       update lstFinalPrdUpdate;

    /*======================UPDATE Book Order Status================================*/  

    Map<Id,string>BookOrderStatusMap= new Map<Id,string>();

    for (Line_Item__c  lt : [SELECT id,name,Book_Order__c,Book_Order__r.Order_Status__c 
                              FROM Line_Item__c  
                             WHERE  Name IN : mapBOLineItem.KeySet() AND Book_Order__c IN : Trigger.NewMap.KeySet()]){  
        if (mapBOPrd.get(lt.Name) != Null){
            if (lstFinalPrdUpdate.size()> 0 && mapBOPrd.get(lt.Name).CONTAINS(lt.Name) && mapNOBOPrd.size()==0)
                BookOrderStatusMap.put(lt.Book_Order__c,'Shipped'); 
        }
        else 
          BookOrderStatusMap.put(lt.Book_Order__c,'Backordered');  
    }

    for (Book_Order__c bo : Trigger.new){
        if(bo.Order_Status__c == 'Ordered')
        bo.Order_Status__c = BookOrderStatusMap.get(bo.Id);
    }
  }
     
}