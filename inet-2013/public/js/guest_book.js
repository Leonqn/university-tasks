// Generated by CoffeeScript 1.6.3
(function() {
  window.edit_post = function(button) {
    var pass, r;
    pass = button.previousElementSibling;
    r = new XMLHttpRequest();
    r.onreadystatechange = function() {
      if (r.readyState !== 4 || r.status !== 200) {
        return;
      }
      if (r.responseText === 'wrngpss') {
        document.querySelector("#post_" + (pass.getAttribute('name')) + " #edit #err").innerHTML = 'Неправильный пароль';
        return;
      }
      return document.querySelector("#post_" + (pass.getAttribute('name')) + " #edit").innerHTML = r.responseText;
    };
    r.open('POST', "/guest/edit/" + (pass.getAttribute('name')), true);
    r.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    return r.send("pass=" + pass.value);
  };

  window.change_post = function(button) {
    var message, post_id, r;
    post_id = button.getAttribute('name');
    message = document.querySelector('.cur_mes textarea');
    r = new XMLHttpRequest();
    r.onreadystatechange = function() {
      if (r.readyState !== 4 || r.status !== 200) {
        return;
      }
      return document.querySelector("#post_" + post_id + " #edit").innerHTML = r.responseText;
    };
    r.open('POST', "/guest/edit/" + post_id);
    r.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    return r.send("mess=" + message.value);
  };

  window.change_cur_pos = function(post) {
    document.querySelector('.cur_pos').setAttribute('class', 'not_cur_pos');
    document.querySelector('.cur_mes').setAttribute('style', 'display: none');
    document.querySelector('.cur_mes').setAttribute('class', 'not_cur_pos');
    document.querySelector("#btn_" + post).setAttribute('class', 'cur_pos');
    document.querySelector("#mes_" + post).removeAttribute('style');
    return document.querySelector("#mes_" + post).setAttribute('class', 'cur_mes');
  };

}).call(this);
