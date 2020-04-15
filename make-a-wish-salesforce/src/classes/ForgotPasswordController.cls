/**
 * @description     An apex page controller that exposes the site forgot password functionality.
 *
 * @author          MST Solutions
 * @createdDate     unknown
 */
public with sharing class ForgotPasswordController {
    public String username { get; set; }
    public Boolean displayAckMsg { get; set; }
    public Boolean success;

    public ForgotPasswordController() {}

    /**
     * @description     Forgot password.
     *
     * @return          PageReference
     *
     * @author          MST Solutions
     * @createdDate     unknown
     */
    public PageReference forgotPassword() {
        List<User> currUser = [SELECT Id FROM User WHERE Username = :username];

        if (currUser.size() > 0) {
            success = Site.forgotPassword(username);

            PageReference pr = Page.ForgotPasswordConfirm;
            pr.setRedirect(true);

            if (success) {
                displayAckMsg = true;
            }
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ForgotPasswordController_Username_Not_Exists);
            ApexPages.addMessage(myMsg);

            return null;
        }

        return null;
    }
}