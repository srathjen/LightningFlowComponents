/**
 * An apex page controller that exposes the change password functionality
 */
//This class used in chamge password VF page
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    //This is the constructor
   	public ChangePasswordController() {}
}