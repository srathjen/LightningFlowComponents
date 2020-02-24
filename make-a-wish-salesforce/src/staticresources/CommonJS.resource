window.commonJS = (function () {
    
    var notifyClassName = 'notification';
    var defaultIntervalSeconds = 4500;
    var itemsArray = localStorage.getItem('items') ? JSON.parse(localStorage.getItem('items')) : [];
    localStorage.setItem('items', JSON.stringify(itemsArray));

    
    function clearIntervalMessage(intervalSec){
        defaultIntervalSeconds = (intervalSec != '') ? intervalSec : defaultIntervalSeconds;
        if(document.getElementById(notifyClassName)) {
            setInterval(function() {
                var elem = document.getElementById(notifyClassName);
                if(elem && elem.parentNode)  elem.parentNode.removeChild(elem);
                
            }, defaultIntervalSeconds);  
        }
    }
    
    function ShowSuccessMsg(message) {
        var div = document.createElement('div');
        div.setAttribute("id", notifyClassName);
        div.className = notifyClassName;
        div.innerHTML = "<div><h6>"+message+"</h6></div>";
        if(document.body != null){ document.body.appendChild(div); }
    }
    
    function setCookie(cname) {
      itemsArray.push(cname);
      localStorage.setItem('items', JSON.stringify(itemsArray));
    }
    
    function getCookie(cname) {
      var result = false;
      var retrievedData = itemsArray;
      if(itemsArray.length){
           result =  (itemsArray.length > 0) ? itemsArray.includes(cname) : false; 
      }
        return result;
    }

    function deleteStorage() {
        localStorage.setItem('items', '')
        window.localStorage.clear(); //try this to clear all local storage
    }
    

    // Reveal public pointers to
    // private functions and properties
    return {
        ShowSuccessMsg: ShowSuccessMsg,
        clearIntervalMessage: clearIntervalMessage,
        setCookie:setCookie,
        getCookie:getCookie,
        deleteStorage:deleteStorage
    };
    
})();
