({
    handleDelete: function(cmp, event, helper) {
        helper.deleteWishSignature(cmp,event);
    },
    
    doInit: function(cmp, event, helper) {
        cmp.find("deleteModal").open();
    },
    
    handleDeleteCancel: function (cmp, event, helper) {
        cmp.set("v.showDeleteModal",false);
        cmp.find("deleteModal").close();
    },
    
})