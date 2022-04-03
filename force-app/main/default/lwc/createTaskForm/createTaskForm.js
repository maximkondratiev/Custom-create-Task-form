import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import getUsers from "@salesforce/apex/CreateTaskFormController.getUsers";
import createTask from "@salesforce/apex/CreateTaskFormController.createTask";

export default class CreateTaskForm extends NavigationMixin(LightningElement) {
  @api recordId;
  isExpanded = false;
  searchUsers = [];
  userId;
  searchInfo;
  dueDate;
  minDateValue;
  description;

  columns = [
    { label: "First Name", fieldName: "FirstName", type: "text" },
    { label: "Last Name", fieldName: "LastName", type: "text" },
    { label: "Email", fieldName: "Email", type: "email" }
  ];

  connectedCallback() {
    let date = new Date();
    this.minDateValue =
      date.getFullYear() +
      "-" +
      (Number(date.getMonth()) + 1) +
      "-" +
      (date.getDate() + 1);
  }

  searchChange(event) {
    this.searchInfo = event.target.value;
  }

  descriptionChange(event) {
    this.description = event.target.value;
  }

  dateChange(event) {
    this.dueDate = event.target.value;
  }

  get disableButton() {
    return !(
      Date.parse(this.dueDate) >= Date.parse(this.minDateValue) &&
      this.description &&
      this.userId
    );
  }

  datatableHandle() {
    this.userId = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows()[0].Id;
  }

  handleUserSearch() {
    getUsers({ input: this.searchInfo })
      .then((result) => {
        this.searchUsers = result;
      })
      .catch((error) => {
        this.error = error;
      });
    this.isExpanded = true;
  }

  navigateToPage(recordID) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordID,
        objectApiName: "Task",
        actionName: "view"
      }
    });
  }
  saveTask() {
    createTask({
      leadId: this.recordId,
      id: this.userId,
      description: this.description,
      dueDate: this.dueDate
    })
      .then((result) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Task created",
            message: "Task was successfully created",
            variant: "success"
          })
        );
        if(result!= null) {
          this.navigateToPage(result);
        }
      })
      .catch((error) => {
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Task Creating Error",
            message: "Something went wrong during the task creating",
            variant: "error"
          })
        );
      });
  }
}
