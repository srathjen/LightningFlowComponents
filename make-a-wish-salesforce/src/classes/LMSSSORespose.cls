/* Created by : MST
Description : This class will be used to parse LMS SSO Response from the Call out.
*/
public class LMSSSORespose {
    public Integer account_id;
    public Integer id;
    public Integer user_id;
    public String token;
    public String created_on;
    public String login_url;
    public String enrollment_url;

    /**
     * @description
     *
     * @param json
     *
     * @return
     */
    public static LMSSSORespose parse(String json) {
        return (LMSSSORespose) System.JSON.deserialize(json, LMSSSORespose.class);
    }
}