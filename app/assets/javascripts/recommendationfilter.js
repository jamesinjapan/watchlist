var filterHash = {
  "c": [],
  "d": []
}

var filterImages = document.querySelectorAll(".img-filter");
var filterButtons = document.querySelectorAll(".btn-filter");

var filterString = "";

function contains(hash, string) {
  if (string[0] in hash) {
    for (var i = 0; i < hash[string[0]].length; i++) {
      if (hash[string[0]][i] === "") {
        return false;
      } else if (hash[string[0]][i] === string.substr(2,string.length)) {
        return true;
      }
    }
    return false;
  } else {
    return false;
  }
}

function find(hash, string) {
  if (string[0] in hash) {
    for (var i = 0; i < hash[string[0]].length; i++) {
      if (hash[string[0]][i] === "") {
        return -1;
      } else if (hash[string[0]][i] === string.substr(2,string.length)) {
        return i;
      }
    }
    return -1;
  } else {
    return false;
  }
}

function addToFilterHash (button) {
  filterHash[button.id[0]].push(button.id.substr(2,button.id.length));
  if (button.tagName == "IMG") {
    button.src = $("#" + button.id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g,'\\$1')).data("off-url");
  };
};

function removeFromFilterHash (button) {
  var loc = find(filterHash[button.id[0]], button.id.substr(2,button.id.length));
  if (loc > -1) {
    filterHash[button.id[0]].splice(loc, 1);
  } 
  if (button.tagName == "IMG") {
    button.src = $("#" + button.id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g,'\\$1')).data("on-url");
  };
};

function filterHashHandler (button) {
  if (contains(filterHash, button.id)) {
    removeFromFilterHash (button);
  } else {
    addToFilterHash (button);
  };
  filterString = jQuery.param(filterHash);
};

var length = 0;
if (filterButtons.length > filterImages.length) {
  length = filterButtons.length
} else {
  length = filterImages.length
};
var i = 0;

for (i; i < length; i++) {
  if (i < filterImages.length) {
    if (document.addEventListener) {
      filterImages[i].addEventListener("click", function() {
        filterHashHandler (this);
      });
    } else {
      buttons[i].attachEvent("onclick", function() {
        filterHashHandler (buttons[i]);
      });
    };
  };
  if (i < filterButtons.length) {
    if (document.addEventListener) {
      filterButtons[i].addEventListener("click", function() {
        filterHashHandler (this);
      });
    } else {
      buttons[i].attachEvent("onclick", function() {
        filterHashHandler (buttons[i]);
      });
    };
  };
};

$('#filter-search').click(function() {
  window.location.href = $(this).attr('href') + "&" + filterString; 
  return false; 
}); 