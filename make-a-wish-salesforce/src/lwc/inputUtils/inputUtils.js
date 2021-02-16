/**
 @description Input utils to promote reuse.
 @author Gustavo Mayer, Traction on Demand
 @createdDate 09/Feb/2021
 **/
export default class InputUtils {
  applyPhoneMask = (val) => {
    const x = val.replace(/\D+/g, "").match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
  };

  validateEmail = (email) => {
    const regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
  };
}