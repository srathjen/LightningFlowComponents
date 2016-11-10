public class WishesTriggerHelperClass{
        public static void updateDateReceived(Map<id,Case> oldMap,List<case> newList){
          for(Case newcase:newList){
                    Case old=oldMap==null?null:oldMap.get(newCase.id);
                    if((newCase.Absent_Parent_Form__c==true && (old==null || (old!=null && old.Absent_Parent_Form__c==false)))){
                      newcase.Date_Received_for_Absent_Parent_Form__c=system.today();
                    }
                    if((newCase.Child_s_Medical_Summary_Form__c==true && (old==null || (old!=null && old.Child_s_Medical_Summary_Form__c==false)))){
                      newCase.Date_Received_for_Child_s_Medical_Summar__c=system.today();         
                    }
                    if((newCase.Communication_Profile__c==true && (old==null || (old!=null && old.Communication_Profile__c==false)))){
                      newCase.Date_Received_for_Communication_Profile__c=system.today();                   
                    }
                    if((newCase.Entertainment_Sports_Wish_LOU__c==true && (old==null || (old!=null && old.Entertainment_Sports_Wish_LOU__c==false)))){
                      newCase.Date_Received_for_Entertainment_Sports__c=system.today();                   
                    }
                    if((newCase.Guardianship_Document__c==true && (old==null || (old!=null && old.Guardianship_Document__c==false)))){
                      newCase.Date_Received_for_Guardianship_Document__c=system.today();                   
                    }
                    if((newCase.Liability_Release_and_Authorization__c ==true && (old==null || (old!=null && old.Liability_Release_and_Authorization__c ==false)))){
                      newCase.Date_Liability_Release_Authorization__c =system.today();
                    }
                    if((newCase.Passports__c==true && (old==null || (old!=null && old.Passports__c==false)))){
                      newcase.Date_Received_for_Passports__c=system.today();
                    }
                    if((newCase.Single_Parent_Form__c==true && (old==null || (old!=null && old.Single_Parent_Form__c==false)))){
                      newcase.Date_Received_for_Single_Parent_Form__c=system.today();
                    }
                    if((newCase.Visas__c==true && (old==null || (old!=null && old.Visas__c==false)))){
                      newcase.Date_Received_for_Visas__c=system.today();
                    }
                    if((newCase.Wish_Safety_Authorization_Part_B_Form__c==true && (old==null || (old!=null && old.Wish_Safety_Authorization_Part_B_Form__c==false)))){
                      newcase.Date_Received_for_Wish_Safety_Authorizat__c=system.today();
                    }

                    if(old!=null){
                        if(newCase.Absent_Parent_Form__c==false){
                          newcase.Date_Received_for_Absent_Parent_Form__c=null;
                        } 
                        if(newCase.Child_s_Medical_Summary_Form__c==false){
                          newCase.Date_Received_for_Child_s_Medical_Summar__c=null;         
                        }
                        if(newCase.Communication_Profile__c==false){
                          newCase.Date_Received_for_Communication_Profile__c=null;                   
                        }
                        if(newCase.Entertainment_Sports_Wish_LOU__c==false){
                          newCase.Date_Received_for_Entertainment_Sports__c=null;                   
                        }
                        if(newCase.Guardianship_Document__c==false){
                          newCase.Date_Received_for_Guardianship_Document__c=null;                   
                        }
                        if(newCase.Liability_Release_and_Authorization__c ==false){
                          newCase.Date_Liability_Release_Authorization__c =null;
                        }
                        if(newCase.Passports__c==false){
                          newcase.Date_Received_for_Passports__c=null;
                        }
                        if(newCase.Single_Parent_Form__c==false){
                          newcase.Date_Received_for_Single_Parent_Form__c=null;
                        }
                        if(newCase.Visas__c==false){
                          newcase.Date_Received_for_Visas__c=null;
                        }
                        if(newCase.Wish_Safety_Authorization_Part_B_Form__c==false){
                          newcase.Date_Received_for_Wish_Safety_Authorizat__c=null;
                        }
                    }
            }      
     }
}