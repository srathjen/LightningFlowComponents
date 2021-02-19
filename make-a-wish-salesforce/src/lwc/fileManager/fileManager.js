/**
 * @description File Manager, component to handle file uploads when we cannot use Lightning File component.
 * @author Gustavo Mayer, Traction on Demand
 * @createdDate 16/Feb/2021
 **/
import { api, LightningElement } from "lwc";
import uploadFile from "@salesforce/apex/FileManagerController.uploadFile";
import findFiles from "@salesforce/apex/FileManagerController.findFiles";
import deleteFile from "@salesforce/apex/FileManagerController.deleteFile";

export default class FileManager extends LightningElement {
  MAX_FILE_SIZE = 3000000;
  files = [];
  file;
  fileContents;
  fileReader;
  content;
  contentType;
  filesUploaded;
  fileName;
  message;

  @api handleLoadFileManager(recordId) {
    this.recordId = recordId;
    this.findFiles();
  }

  handleFilesChange(event) {
    if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      const file = event.target.files[0];
      this.fileName = file.name;
      this.contentType = file.type;
    }
    if (this.filesUploaded.length > 0) {
      this.file = this.filesUploaded[0];
      if (this.file.size > this.MAX_FILE_SIZE) {
        this.addMessageCustomStyle("File cannot be bigger than 3MB.", false);
      } else {
        const spinner = this.template.querySelectorAll(".spinner");
        this.show(spinner);
        this.fileReader = new FileReader();
        this.fileReader.onloadend = () => {
          this.fileContents = this.fileReader.result;
          let base64 = "base64,";
          this.content = this.fileContents.indexOf(base64) + base64.length;
          this.fileContents = this.fileContents.substring(this.content);
          this.saveFile();
        };
        this.fileReader.readAsDataURL(this.file);
      }
    }
  }

  saveFile() {
    const file = {
      parentId: this.recordId,
      fileName: this.file.name,
      base64Data: encodeURIComponent(this.fileContents),
      contentType: this.contentType,
    };
    uploadFile({ file })
      .then((result) => {
        this.delayTimeout = setTimeout(() => {
          this.findFiles();
          const spinner = this.template.querySelectorAll(".spinner");
          this.hide(spinner);
          this.addMessageCustomStyle("File uploaded.", true);
        }, 10000);
      })
      .catch((error) => {
        const spinner = this.template.querySelectorAll(".spinner");
        this.hide(spinner);
        this.addMessageCustomStyle("Error while uploading file.", false);
      });
  }

  handleRefresh() {
    const spinner = this.template.querySelectorAll(".spinner");
    this.show(spinner);
    this.delayTimeout = setTimeout(() => {
      this.findFiles();
      const spinner = this.template.querySelectorAll(".spinner");
      this.hide(spinner);
    }, 3000);
  }

  handleDeleteFile(event) {
    const spinner = this.template.querySelectorAll(".spinner");
    this.show(spinner);
    let fileId = event.target.dataset.id;
    deleteFile({ fileId })
      .then((result) => {
        this.delayTimeout = setTimeout(() => {
          this.findFiles();
          const spinner = this.template.querySelectorAll(".spinner");
          this.hide(spinner);
        }, 3000);
      })
      .catch((error) => {
        console.log(error);
        const spinner = this.template.querySelectorAll(".spinner");
        this.hide(spinner);
        this.addMessageCustomStyle("Error while deleting file.", false);
      });
  }

  findFiles() {
    const parentId = this.recordId;
    findFiles({ parentId })
      .then((result) => {
        let files = [];
        result.forEach((element) => {
          files.push({
            fileId: element.fileId,
            fileName: element.fileName,
          });
        });
        this.files = files;
      })
      .catch((error) => {
        const spinner = this.template.querySelectorAll(".spinner");
        this.hide(spinner);
        this.addMessageCustomStyle("Error while retrieving file.", false);
      });
  }

  get hasFiles() {
    return this.files.length > 0;
  }

  addMessageCustomStyle(message, isSuccess) {
    const element = this.template.querySelector(".message");
    if (isSuccess) {
      this.message = message;
      element.classList.remove("messageError");
      element.classList.add("messageSuccess");
    } else {
      this.message = "File cannot be bigger than 15MB.";
      this.message = message;
      element.classList.remove("messageSuccess");
      element.classList.add("messageError");
    }
    const messages = this.template.querySelectorAll(".message");
    this.show(messages);
    this.delayTimeout = setTimeout(() => {
      this.hide(messages);
    }, 5000);
  }

  show(elms) {
    elms.forEach((element) => {
      element.classList.remove("slds-hide");
      element.classList.add("slds-show");
    });
  }

  hide(elms) {
    elms.forEach((element) => {
      element.classList.add("slds-hide");
      element.classList.remove("slds-show");
    });
  }
}
