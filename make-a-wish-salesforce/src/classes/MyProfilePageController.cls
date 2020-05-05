/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {
    
    private User user;
    private boolean isEdit = false;
    
    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }
    
    public User getUser() {
        return user;
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    /**
    * Enables edit mode
    */
    public void edit() {
        isEdit=true;
    }
    
    /**
    * Updates user information
    */
    public void save() {
        try {
            update user;
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    /**
    * Redirects to change password page
    */
    public PageReference changePassword() {
        return Page.ChangePassword;
    }
    
    /**
    * Cancels edit mode
    */
    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }    
}