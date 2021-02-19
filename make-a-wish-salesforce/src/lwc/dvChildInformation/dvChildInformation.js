import { LightningElement, api, wire, track } from "lwc";
import getLeadChildInformation from "@salesforce/apex/DVChildInfoController.getLeadChildInformation";

export default class DVChildInformation extends LightningElement {
  leadId;
  leadInfo;
  leadName;
  gender;
  dob;
  parentGuardianName;
  referrerName;
  relationshipToChild;
  diagnosisGivenByReferrer;
  icdGivenByReferrer;

  @api handleLoadChildInformation(leadId) {
    this.leadId = leadId;
  }

  @wire(getLeadChildInformation, {
    leadId: "$leadId"
  })
  wired(result) {
    if (result.data) {
      console.log(" JSON... " + JSON.stringify(result.data));
      this.leadName = result.data.name;
      this.gender = result.data.gender;
      this.dob = result.data.dob;
      this.parentGuardianName = result.data.parentGuardianName;
      this.referrerName = result.data.referrerName;
      this.relationshipToChild = result.data.relationshipToChild;
      this.diagnosisGivenByReferrer = result.data.diagnosisGivenByReferrer;
      this.icdGivenByReferrer = result.data.icdGivenByReferrer;
      this.leadInfo = result.data;
    } else if (result.error) {
      console.error(result.error);
    }
  }
}
