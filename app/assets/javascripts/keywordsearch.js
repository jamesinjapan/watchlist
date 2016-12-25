var keywordHash = {
  "k": [],
  "g": []
}

var keywordButtons = document.querySelectorAll(".btn-keyword");

var keywordString = "";

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

function addToKeywordHash (button) {
  keywordHash[button.id[0]].push(button.id.substr(2,button.id.length));
};

function removeFromKeywordHash (button) {
  var loc = find(keywordHash[button.id[0]], button.id.substr(2,button.id.length));
  if (loc > -1) {
    keywordHash[button.id[0]].splice(loc, 1);
  } 
};

function keywordHashHandler (button) {
  if (contains(keywordHash, button.id)) {
    removeFromKeywordHash (button);
  } else {
    addToKeywordHash (button);
  };
  keywordString = jQuery.param(keywordHash);
};

var i = 0, length = keywordButtons.length;

for (i; i < length; i++) {
  if (document.addEventListener) {
    keywordButtons[i].addEventListener("click", function() {
      keywordHashHandler (this);
    });
  } else {
    buttons[i].attachEvent("onclick", function() {
      keywordHashHandler (buttons[i]);
    });
  };
};

$('#keyword-search').click(function() {
  window.location.href = $(this).attr('href') + "?" + keywordString; 
  return false; 
}); 

$('#keyword-hide').click(function() {
  window.location.href = $(this).attr('href') + "?" + keywordString; 
  return false; 
}); 