/***********************************************************************
Description : Sharing the records to Chatper Staff with Read & Write permission 
for their corresponding chapter records.
************************************************************************/

Public class ChapterStaffRecordSharing_AC
{
   public static void LeadSharing(Map<String,List<Lead>> leadMap)
   {
     /*  Map<String, String> ChapterRoleMap = FindChapterRole(leadMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<LeadShare> leadsToShare = new List<LeadShare>();
      for(String currChapter : leadMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Lead currLead : leadMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       LeadShare currSharing = new LeadShare();
                       currSharing.leadId = currLead.id;
                       currSharing.UserOrGroupId = currUser.id;//.subString(0,15);//'00536000001rItA';//currVolunteer.subString(0,15);
                       currSharing.leadAccessLevel = 'Edit';
                       currSharing.RowCause = Schema.LeadShare.RowCause.Manual;
                       leadsToShare.add(currSharing);
                  }
               }
             }
         }
        
      } */
      
     // if(leadsToShare.size() > 0)
         // insert leadsToShare;
      
   
   }
   
   public static void ContactSharing(Map<String,List<Contact>> contactMap)
   {
     /* Map<String, String> ChapterRoleMap = FindChapterRole(contactMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<ContactShare> contactsToShare = new List<ContactShare>();
      for(String currChapter : contactMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Contact currCon : contactMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       ContactShare currSharing = new ContactShare();
                       currSharing.contactId = currCon.id;
                       currSharing.UserOrGroupId = currUser.id;
                       currSharing.contactAccessLevel = 'Edit';
                       currSharing.RowCause = Schema.ContactShare.RowCause.Manual;
                       contactsToShare.add(currSharing);
                  }
               }
             }
         }
      } */
      
     /* if(contactsToShare.size() > 0)
          insert contactsToShare;*/
      
   
   }
   
   public static void AccountSharing(Map<String,List<Account>> accountMap)
   {
     /* Map<String, String> ChapterRoleMap = FindChapterRole(accountMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<AccountShare> accountsToShare = new List<AccountShare>();
      for(String currChapter : accountMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Account currAcc : accountMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       AccountShare currSharing = new AccountShare();
                       currSharing.accountId = currAcc.id;
                       currSharing.UserOrGroupId = currUser.id;
                       currSharing.accountAccessLevel = 'Edit';
                       currSharing.OpportunityAccessLevel = 'Read';
                       currSharing.CaseAccessLevel = 'Read';
                       currSharing.ContactAccessLevel = 'Read';
                       
                       currSharing.RowCause = Schema.AccountShare.RowCause.Manual;
                       accountsToShare.add(currSharing);
                  }
               }
             }
         }
      }*/
      
     // if(accountsToShare.size() > 0)
       //   insert accountsToShare;
          
        //  System.debug('Accountssharing++++++++++++++++++++++++++++++++++ ' +accountsToShare); 
      
   
   }
   
   
   public static void CaseSharing(Map<String,List<Case>> CaseMap)
   {
     /* Map<String, String> ChapterRoleMap = FindChapterRole(CaseMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<CaseShare> casesToShare = new List<CaseShare>();
      for(String currChapter : CaseMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Case currCase : CaseMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       CaseShare currSharing = new CaseShare();
                       currSharing.caseId = currCase.id;
                       currSharing.UserOrGroupId = currUser.id;
                       currSharing.caseAccessLevel = 'Edit';
                       currSharing.RowCause = Schema.caseShare.RowCause.Manual;
                       casesToShare.add(currSharing);
                  }
               }
             }
         }
      } */
      
    //  if(casesToShare.size() > 0)
         // insert casesToShare;
      
   
   }
   
   
   Public static void BGCRecordSharing(Map<String,List<Background_check__c>> bgcRecordMap)
   {
      Map<String, String> ChapterRoleMap = FindChapterRole(bgcRecordMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<Background_check__Share> bgcToShare = new List<Background_check__Share>();
      for(String currChapter : bgcRecordMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Background_check__c currBGC : bgcRecordMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       Background_check__Share currSharing = new Background_check__Share();
                       currSharing.ParentId = currBGC.id;
                       currSharing.UserOrGroupId = currUser.id;
                       currSharing.AccessLevel = 'Read';
                       currSharing.RowCause = 'Chapter_Staff__c';
                       bgcToShare.add(currSharing);
                  }
               }
             }
         }
      
      }
      
      if(bgcToShare.size() > 0)
         insert bgcToShare;
      }
   
   
    Public static void COIRecordSharing(Map<String,List<Conflict_Of_Interest__c>> coiRecordMap)
   {
      Map<String, String> ChapterRoleMap = FindChapterRole(coiRecordMap.keySet());
      Map<String,List<User>> userMap = userRecMap(ChapterRoleMap.values());
      List<Conflict_Of_Interest__Share> coiToShare = new List<Conflict_Of_Interest__Share>();
      for(String currChapter : coiRecordMap.keySet())
      {
         if(ChapterRoleMap.containsKey(currChapter))
         {
             if(userMap.containsKey(ChapterRoleMap.get(currChapter)))
             {
               for(Conflict_Of_Interest__c currCOI : coiRecordMap.get(currChapter))
               {
                  for(User currUser : userMap.get(ChapterRoleMap.get(currChapter)))
                  {
                       Conflict_Of_Interest__Share currSharing = new Conflict_Of_Interest__Share();
                       currSharing.ParentId = currCOI.id;
                       currSharing.UserOrGroupId = currUser.id;
                       currSharing.AccessLevel = 'Read';
                       currSharing.RowCause = 'Chapter_Staff__c';
                       coiToShare.add(currSharing);
                  }
               }
             }
         }
      
      }
      
      if(coiToShare.size() > 0)
         insert coiToShare;
      }
   
   
   
   public static Map<String,List<User>> userRecMap(List<String> usersRole)
   {
      Map<String,List<User>> userMap = new Map<String,List<User>>();
   
      for(User currUser : [SELECT id,userrole.Name FROM User WHERE userrole.name in :usersRole AND isActive=True])
      {
          if(userMap.containsKey(currUser.userrole.Name))
              userMap.get(currUser.userrole.Name).add(currUser);
          else
              userMap.put(currUser.userrole.Name, new list<user>{currUser});
             
      }
      
      return userMap;
   }
   
   public static Map<String, String> FindChapterRole(Set<String> chaptersSet)
   {
      Map<String, String> ChapterRoleMap = new Map<String, String>();
      for(Chapter_Vs_Role__c currChapterRole : [SELECT Chapter_Name__c, Role_Name__c FROM Chapter_Vs_Role__c WHERE Chapter_Name__c IN : chaptersSet])
      {
          ChapterRoleMap.put(currChapterRole.Chapter_Name__c,currChapterRole.Role_Name__c);
      }
      
      return ChapterRoleMap;
   }

}